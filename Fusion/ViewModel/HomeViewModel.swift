//
//  HomeViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 23/02/2024.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel: NSObject, ObservableObject {
    
    @Published var users: [User] = []
    @Published var selectedUser: User?
    @Published var isLoading = false
    @Published var presentMatchingNotifiaction = false
    @Published var swipedOnUsers: [SwipedOnUser] = []
    var locationManager: CLLocationManager = CLLocationManager() //responsible fetching users location using their device
    var userLocation: CLLocation? //storing the users location
    
    //ask user for permission to get location
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func createMessageThread(withUser userID: String, matchingUser: User, currentUser: User ) { //getting our user id and the other persons user id in order to create a message thread
        guard let ourUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let threadID = UUID().uuidString
        var otherUserData = [
            "threadID": threadID,
            "username": matchingUser.fullname
        ]
        if let avatar = matchingUser.avatar {
            otherUserData["avatar"] = avatar
        }
        var userData = [
            "threadID": threadID,
            "username": currentUser.fullname
        ]
        if let avatar = currentUser.avatar {
            userData["avatar"] = avatar
        }
        Firestore.firestore().collection("users").document(userID).collection("messageThreads").document(ourUserID).setData(userData)
        Firestore.firestore().collection("users").document(ourUserID).collection("messageThreads").document(userID).setData(otherUserData)
    }
    
    func requestLocation() {
        isLoading = true
        locationManager.requestLocation()
    }
    
    func swiped(user:User,isRight:Bool) {  //function for swiping right
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        Firestore.firestore().collection("swiped").addDocument(data: [
            "user" : userID,
            "swipedOn" : user.id,
            "isRight" : isRight
        ])
    }
    
    func isInRange(user: User, ofLocation location: CLLocation, range: Double) -> Bool {
        let latitude = user.l[0]
        let longitude = user.l[1]
        
        let otherUserLocation = CLLocation(latitude: latitude, longitude: longitude)  //other user's location
        
        let distance = getDistance(originLocation: location, destinationLocation: otherUserLocation)
        return distance < range
    }
    
    func getDistance(originLocation: CLLocation, destinationLocation: CLLocation) -> Double {
        return originLocation.distance(from: destinationLocation)
    }
    
}

extension HomeViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { //safety net for location incase it fails
        isLoading = false
        print(error.localizedDescription)
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { //tells me if authorization has changed
        print("authorization status \(manager.authorizationStatus)")
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
    func getUsersAlreadySwipedOn(completion: @escaping ([SwipedOnUser]) -> Void) { //function for collecting of users that we have been swiped on and should not see again in our list of results
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        Firestore.firestore().collection("swiped").whereField("user", isEqualTo: userID).getDocuments { snapshot, error in //gives all users that you have swiped on before
            if let error = error { //incase of an error
                completion([])
                print(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {
                completion([])
                return
            }
            let swipedUsers: [SwipedOnUser] = snapshot.documents.compactMap { querySnapshot in //record of users who have swiped left or right
                let data = querySnapshot.data()
                guard let swipedOnUserID = data["swipedOn"] as? String else {
                    return nil
                }
                guard let isRight = data["isRight"] as? Bool else {
                    return nil
                }
                return SwipedOnUser(userID: swipedOnUserID, isRight: isRight)
            }
           completion(swipedUsers) //call completion and pass swipedUsers in app
        }
    }
    
    func getUsersWhoSwipedOnUs(completion: @escaping ([SwipedOnUser]) -> Void) { //expecting an array of users of users who swiped on us
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        Firestore.firestore().collection("swiped").whereField("swipedOn", isEqualTo: userID).getDocuments { snapshot, error in //gives all users that you have swiped on before
            if let error = error { //incase of an error
                completion([])
                print(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else {
                completion([])
                return
            }
            let swipedUsers: [SwipedOnUser] = snapshot.documents.compactMap { querySnapshot in //record of users who have swiped left or right
                let data = querySnapshot.data()
                guard let swipedOnUserID = data["user"] as? String else {
                    return nil
                }
                guard let isRight = data["isRight"] as? Bool else {
                    return nil
                }
                return SwipedOnUser(userID: swipedOnUserID, isRight: isRight)
            }
           completion(swipedUsers) //call completion and pass swipedUsers in app
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first,
        let userID = Auth.auth().currentUser?.uid else { //pulls first result of users location and saves it
            isLoading = false
            return
        }
        self.userLocation = userLocation
        User.updateUserLocation(location: userLocation)
        getUsersAlreadySwipedOn { alreadySwipedOnUsers in
            self.getUsersWhoSwipedOnUs { swipedOnUsers in
                self.swipedOnUsers.removeAll()
                self.swipedOnUsers = swipedOnUsers
                print("swiped on users \(swipedOnUsers)")
                Firestore.firestore().collection("users").getDocuments { snapshot, error in
                    if let error = error {
                        self.isLoading = false
                        return
                    }
                    guard let snapshot = snapshot else {
                        self.isLoading = false
                        return
                    }
                    let allUsers = snapshot.documents.compactMap({ User(snapshot: $0) })
                    var eligibleUsers: [User] = [] //adds eligible users into this array for users who are in the area
                    print("my location lat \(userLocation.coordinate.latitude) and long \(userLocation.coordinate.longitude) ")
                    
                    let numberFormatter = NumberFormatter() //formatting km shown on profile
                    numberFormatter.maximumFractionDigits = 1
                    
                        
                    for user in allUsers {
                        guard user.id != userID else { //code to not add in main user into swiping feature
                            continue
                        }
                        
                        if self.isInRange(user: user, ofLocation: userLocation, range: 1000000) {
                            var mutableUser = user
                            let distance = self.getDistance(originLocation: userLocation, destinationLocation: CLLocation(latitude: user.l[0], longitude: user.l[1]))
                            let formattedDistanceAway = numberFormatter.string(from: (distance / 1000) as NSNumber ) ?? "0"  //adding in formatted distance
                            mutableUser.distanceAway = "\(formattedDistanceAway) km away" //shows the amount of km away on user profile
                            eligibleUsers.append(mutableUser)
                        }

                    }
                    self.isLoading = false
                    let filteredUsers = eligibleUsers.filter({ user in //adding in a filter for users that have swiped left so they dont appear again
                        if let swipedOnUser = swipedOnUsers.first(where: { $0.userID == user.id }) {
                            return swipedOnUser.isRight
                        }
                       return true
                    })
                    let unswipedUsers = filteredUsers.filter { user in //compares users to users we have swiped on vs the users that are in radius
                         !alreadySwipedOnUsers.contains(where: { $0.userID == user.id }) //this filter excludes the users from the home view
                    }
                    self.users = unswipedUsers
                }
                
            }
        }
        
        
        
       
//        let geoFireStoreRef = Firestore.firestore().collection("users") //observers users that move
//        let geoFireStore = GeoFirestore(collectionRef: geoFireStoreRef) //knows which document to look in and looks at location from all users and pulls all the users from the location
//        var circleQuery = geoFireStore.query(withCenter: userLocation, radius: 1) //radius of 1 is 1000m
//        let queryHandle = circleQuery.observe(.documentEntered) { key, location in
//        }
    }
    
}
