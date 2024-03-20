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
    var locationManager: CLLocationManager = CLLocationManager() //responsible fetching users location using their device
    
    //ask user for permission to get location
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        print("did request location")
        isLoading = true
        locationManager.requestLocation()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first,
        let userID = Auth.auth().currentUser?.uid else { //pulls first result of users location and saves it
            isLoading = false
            return
        }
        User.updateUserLocation(location: userLocation)
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
            var eligibleUsers: [User] = []
            print("my location lat \(userLocation.coordinate.latitude) and long \(userLocation.coordinate.longitude) ")
            
            let numberFormatter = NumberFormatter() //formatting km shown on profile
            numberFormatter.maximumFractionDigits = 1
            
                
            for user in allUsers {
                guard user.id != userID else { //code to not add in main user into swiping feature
                    continue
                }
                let latitude = user.l[0]
                let longitude = user.l[1]
                
                let otherUserLocation = CLLocation(latitude: latitude, longitude: longitude)  //other user's location
                
                let distance = userLocation.distance(from: otherUserLocation)
                print("distance to \(user.fullname) is \(distance) and lat \(latitude) and long \(longitude) ") //output in console, seeing other users location in relative to main user
                
                if distance < 1000000 { //radius is 1000km to find users
                    var mutableUser = user
                    let formattedDistanceAway = numberFormatter.string(from: (distance / 1000) as NSNumber ) ?? "0"  //adding in formatted distance
                    mutableUser.distanceAway = "\(formattedDistanceAway) km away" //shows the amount of km away on user profile
                    eligibleUsers.append(mutableUser)
                }
            }
            self.isLoading = false
            self.users = eligibleUsers
        }
        
       
//        let geoFireStoreRef = Firestore.firestore().collection("users") //observers users that move
//        let geoFireStore = GeoFirestore(collectionRef: geoFireStoreRef) //knows which document to look in and looks at location from all users and pulls all the users from the location
//        var circleQuery = geoFireStore.query(withCenter: userLocation, radius: 1) //radius of 1 is 1000m
//        let queryHandle = circleQuery.observe(.documentEntered) { key, location in
//        }
    }
    
}
