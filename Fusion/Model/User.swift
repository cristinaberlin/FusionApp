//
//  User.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/12/2023.
//
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

/*
 The UserModel describes all the attributes of a user in the app
 */
struct User: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let fullname: String
    let email: String
    let businessField: BusinessFields
    var company: String?
    var experience: String?
    var bio: String?
    var avatar: String?
    var l: [Double] = [] //location
    var distanceAway: String?
    
    init(id:String, fullname: String, email: String, businessField: BusinessFields, company: String? = nil, experience: String? = nil, bio: String? = nil, avatar: String? = nil, l:[Double] = [] ) {
        self.id = id
        self.fullname = fullname
        self.email = email
        self.businessField = businessField
        self.company = company
        self.experience = experience
        self.bio = bio
        self.avatar = avatar
        self.l = l
    }
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        guard let fullname = data["fullname"] as? String else {return nil}
        guard let email = data["email"] as? String else {return nil}
        guard let businessFieldRawValue = data["businessField"] as? Int,
              let businessField = BusinessFields(rawValue: businessFieldRawValue) else {return nil}
        guard let l = data["l"] as? [Double] else {return nil}
        self.id = snapshot.documentID
        self.fullname = fullname
        self.email = email
        self.businessField = businessField
        self.l = l
        if let company = data["company"] as? String {
            self.company = company
        }
        if let experience = data["experience"] as? String {
            self.experience = experience
        }
        if let bio = data["bio"] as? String {
            self.bio = bio
        }
        if let avatar = data["avatar"] as? String {
            self.avatar = avatar
        }
        
    }
    
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) { //looks at full name and grabs initials
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    
    
    static func updateUserLocation(location: CLLocation) { //starting to use geo fire store with user location, here I am storing it
        // Here I use the location taken and use it with geofirestore and make a query with the users in the area(radius of users within 1000km)
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let geoFireStoreRef = Firestore.firestore().collection("users")
        let geoFireStore = GeoFirestore(collectionRef: geoFireStoreRef)
        geoFireStore.setLocation(geopoint: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), forDocumentWithID: userID) { error in
        }
    }
    
}

//This extension creates mock users for testing purposes
extension User{
    static func createMockLocationUsers() {
        func upload(image: UIImage) async -> URL? { //function uploads the avatar to firebase and will be shown in app
                guard let userId = Auth.auth().currentUser?.uid else { return nil }
                guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }
                let imageID = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
                let imageName = imageID + ".jpeg"
                let imagePath = "images/\(userId)/\(imageName)"
                let storageRef = Storage.storage().reference(withPath: imagePath)
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
            do {
                        let _ = try await storageRef.putDataAsync(imageData, metadata: metaData) { progress in
                        }
                        let downloadURL = try await storageRef.downloadURL()
                        return downloadURL
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                    return nil
                }
        @Sendable func updateUserLocation(userID: String, latitude: Double, longitude: Double) { //starting to use geo fire store with user location, here I am storing it
            // Here I use the location taken and use it with geofirestore and make a query with the users in the area(radius of users within 1000km)
            let geoFireStoreRef = Firestore.firestore().collection("users")
            let geoFireStore = GeoFirestore(collectionRef: geoFireStoreRef)
            geoFireStore.setLocation(geopoint: GeoPoint(latitude: latitude, longitude: longitude), forDocumentWithID: userID) { error in
            }
        }
        @Sendable func createUser(user: User, latitude: Double, longitude: Double) async  { //creates a user in background with firebase
            
            do {
                let result = try await Auth.auth().createUser(withEmail: user.email, password: "1234abc!")
                let user = User(id: result.user.uid, fullname:  user.fullname, email: user.email, businessField: user.businessField)
                guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
                try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
                updateUserLocation(userID: result.user.uid, latitude: latitude, longitude: longitude)
            } catch {
                let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            }
        }
        let mockUsers = User.mockUsers //mockusers location
        Task {
            await createUser(user: mockUsers[0], latitude: 53.61516818024476, longitude: -6.197533607482911)
            await createUser(user: mockUsers[1], latitude: 53.61292784933422, longitude: -6.189894676208496)
            await createUser(user: mockUsers[2], latitude: -6.189894676208496, longitude: -6.184659004211427)
        }
    }
    static let mockUsers: [User] = [
        User(id: UUID().uuidString, fullname: "Pink Panther", email: "panther32@gmail.com", businessField: .hospitality, company: "Hilton", experience: "3 years", bio: "I love cheese", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Ana Banana", email: "ana123@icloud.com", businessField: .fashion, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Tony B", email: "tony98@icloud.com", businessField: .automotive, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Alejandro D", email: "ad32@icloud.com", businessField: .healthcare, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Kevin B", email: "kevin28@icloud.com", businessField: .accounting, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Alexandra T", email: "alex@icloud.com", businessField: .technology, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab"),
        User(id: UUID().uuidString, fullname: "Amelia B", email: "amelia6@icloud.com", businessField: .marketing, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab")
        
    ]
}
