//
//  FusionApp.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 06/12/2023.
//  App Development Inspired by: https://www.youtube.com/watch?v=HJDCXdhQaP0&ab_channel=CodeWithChris by Code with Chris' Playlist
//  Authentication Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff
//

import SwiftUI
import Firebase

//The app delegate is the place where I can add code to run when app is launched
//When app launches I need to configure firebase to work
// Step 5 in firebase documentation https://firebase.google.com/docs/ios/setup#swift
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure() //required for when using firebase, making sure firebase is ready to go when app opens
    return true
  }
}

//@main is an annotation that is used to mark the app's entry point
@main
struct FusionApp: App {
    //SessionManager is used to manage the user's session state i.e whether they are logged in or not
   @StateObject var sessionManager = SessionManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

/*
 I use a switch statement on session manager to determine whether user is logged in or not
 If the user is logged out the session state triggers the case .loggedOut which then then brings up the LoginView which requires the user to either log in or sign up
 IF the user is logged in the session state triggers the case .loggedIn which brings the tab view which is a collection of the HomeView, MessagingView and ProfileView
 */
    var body: some Scene {
        WindowGroup {
            switch sessionManager.sessionState {
            case .loggedOut:
                LoginView()
                    .environmentObject(sessionManager)
                    .preferredColorScheme(.light)
            case .loggedIn:
                TabView {
             
                    MessagingView()
                        .tabItem {
                            VStack{
                                Image(systemName: "bubble")
                                Text("Messages")
                            }
                        }
                    
                    HomeView()
                        .tabItem {
                            VStack{
                                Image(systemName: "house")
                                Text("Home")
                            }
                        }
                    
                    
                    ProfileView()
                        .tabItem {
                            VStack{
                                Image(systemName: "person")
                                Text("Account")
                            }
                        }
                    
                  
                    
                }
                .environmentObject(sessionManager)
                .preferredColorScheme(.light)
            }
               
                
        }
        
    }
}

