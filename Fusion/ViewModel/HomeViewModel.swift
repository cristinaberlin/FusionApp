//
//  HomeViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 23/02/2024.
//
//  Recommender Algorithm - Linear Regression https://www.kodeco.com/34652639-building-a-recommendation-app-with-create-ml-in-swiftui
//  CreateML: https://developer.apple.com/machine-learning/create-ml/
//  Requesting Authorisation for location: https://developer.apple.com/documentation/corelocation/requesting_authorization_to_use_location_services

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

/*
 The HomeViewModel is responsible for the logic behind the HomeView.
 It's functions include:
  -  Running the recommendations algorithm
  -  Storing likes and dislikes in firebase
  -  Getting the user's current location
  -  Finding other user's within a certain radius from the current user
  -  Creating a message thread if user's match
  
  Corelocation is a module in apple that is used to get the user's location: https://developer.apple.com/documentation/corelocation
 */
class HomeViewModel: NSObject, ObservableObject {
    
    @Published var users: [User] = []
    @Published var recommendations: [User] = []
    var allUsers: [FavoriteWrapper<User>] = []
    @Published var selectedUser: User?
    @Published var isLoading = false
    @Published var presentMatchingNotifiaction = false
    @Published var showRecommendations = false
    @Published var swipedOnUsers: [SwipedOnUser] = []
    var locationManager: CLLocationManager = CLLocationManager() //responsible fetching users location using their device
    var userLocation: CLLocation? //storing the users location
    private let recommendationStore = RecommendationStore()
    private var recommendationsTask: Task<Void, Never>?
    var swipedUsers: [User] = []
    
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    //This function is responsible for making a recommendation based on whether the user liked or disliked
    // It uses the CreateML to train a machine learning model everytime there is a like or dislike https://developer.apple.com/machine-learning/create-ml/
    func makeRecommendation(user: User, isLiked: Bool) { //function for making recommendation, function is from TshirtFinder
        if let index = allUsers.firstIndex(where: {
            $0.model.id == user.id //find the id of user I have just liked or unliked from array of all users
        }) {
            allUsers[index] = FavoriteWrapper(model: user, isFavorite: isLiked)
        }
        recommendationsTask?.cancel()
        recommendationsTask = Task {
            do {
                let result = try await recommendationStore.computeRecommendations(basedOn: allUsers)
                if !Task.isCancelled {
                    var filteredResults = result
                    for user in swipedUsers {
                        filteredResults.removeAll(where: { $0.id == user.id })
                    }
                    recommendations = filteredResults
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //This function is responisble for creating a message thread if user's match - it is stored in firebase
    func createMessageThread(withUser userID: String, matchingUser: User, currentUser: User ) { //getting our user id and the other persons user id in order to create a message thread
        guard let ourUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let threadID = UUID().uuidString
        var otherUserData = [
            "threadID": threadID,
            "username": matchingUser.fullname,
            "otherUserID": userID
        ]
        if let avatar = matchingUser.avatar {
            otherUserData["avatar"] = avatar
        }
        var userData = [
            "threadID": threadID,
            "username": currentUser.fullname,
            "otherUserID": ourUserID
        ]
        if let avatar = currentUser.avatar {
            userData["avatar"] = avatar
        }
        Firestore.firestore().collection("users").document(userID).collection("messageThreads").document(ourUserID).setData(userData)
        Firestore.firestore().collection("users").document(ourUserID).collection("messageThreads").document(userID).setData(otherUserData)
    }
    
    //This function is responsible for asking the user for permission to get their location
    //Apple only allows the module corelocation to share user location if the user permits it, for privacy protection https://developer.apple.com/documentation/corelocation/requesting_authorization_to_use_location_services
    func requestLocation() {
        isLoading = true
        locationManager.requestLocation()
    }
    
    //This function is responsible for creating a reference to firestore for storing whether a user liked or disliked another user
    @discardableResult
    func swiped(user: User, isRight:Bool, currentUserID: String) async -> DocumentReference? {
       let documentReference = try? await Firestore.firestore().collection("swiped").addDocument(data: [
            "user" : currentUserID,
            "swipedOn" : user.id,
            "isRight" : isRight
        ])
        return documentReference
    }
    
    //This function is responsible for checking to see if the current user is within the 500km radius
    func isInRange(user: User, ofLocation location: CLLocation, range: Double) -> Bool {
        let latitude = user.l[0]
        let longitude = user.l[1]
        
        let otherUserLocation = CLLocation(latitude: latitude, longitude: longitude)  //other user's location
        
        let distance = getDistance(originLocation: location, destinationLocation: otherUserLocation)
        return distance < range
    }
    
    //This function is responsible for getting the distance between the two points
    //The two points are expressed as CLLocation which means the distance between the two are measured as the distance between two latitude and longitude coordinates
    func getDistance(originLocation: CLLocation, destinationLocation: CLLocation) -> Double {
        return originLocation.distance(from: destinationLocation)
    }
    
}

extension HomeViewModel: CLLocationManagerDelegate {
    //This function is required by corelocation although I dont make much use of it, it informs me if anything goes wrong when fetching a location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        print(error.localizedDescription)
        
    }
    
    //This function is responsible for informing me whether the user changes their location permissions
    //If the user permits the use of their location, Fusion immediately attempts to find their location
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("authorization status \(manager.authorizationStatus)")
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
    //This function is responsible for getting users the currecnt user has already swiped on
    //This is to ensure these users are not included again in the swipe cards
    func getUsersAlreadySwipedOn(completion: @escaping ([SwipedOnUser]) -> Void) {
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
    
    //This function is responsible for getting users who have swiped left on us
    // I do not include users in the swipe cards who have already swiped left on the current user
    func getUsersWhoSwipedOnUs(completion: @escaping ([SwipedOnUser]) -> Void) {
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
    
    //This function is only called when the user has permitted access to their location
    //This function is responsible for getting the user's location and finding other users who is in within the radius
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
                        print(error.localizedDescription) //prints our if an error has occurred and it describes it
                        self.isLoading = false
                        return
                    }
                    guard let snapshot = snapshot else {
                        self.isLoading = false
                        return
                    }
                    let allUsers = snapshot.documents.compactMap({ User(snapshot: $0) })
                    var eligibleUsers: [User] = [] //adds eligible users into this array for users who are in the area
                   // print("my location lat \(userLocation.coordinate.latitude) and long \(userLocation.coordinate.longitude) ")
                    
                    let numberFormatter = NumberFormatter() //formatting km shown on profile
                    numberFormatter.maximumFractionDigits = 1
                    
                        
                    for user in allUsers {
                        guard user.id != userID else { //code to not add in main user into swiping feature
                            continue
                        }
                        
                        if self.isInRange(user: user, ofLocation: userLocation, range: 500000) { //500km radius
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
                    print("total users \(unswipedUsers.count)")
                    self.users = unswipedUsers
                    self.allUsers = unswipedUsers.map({ FavoriteWrapper(model: $0) })
                }
                
            }
        }
    }
}
