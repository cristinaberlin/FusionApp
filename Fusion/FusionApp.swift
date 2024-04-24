//
//  FusionApp.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 06/12/2023.
//  Inspired by: https://www.youtube.com/watch?v=HJDCXdhQaP0&ab_channel=CodeWithChris by Code with Chris
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure() //required for when using firebase, making sure firebase is ready to go when app opens
    return true
  }
}

@main
struct FusionApp: App {
   @StateObject var sessionManager = SessionManager() //initialised here and used throughout the app
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

      
    var body: some Scene {
        WindowGroup {
            switch sessionManager.sessionState {
            case .loggedOut:
                LoginView()
                    .environmentObject(sessionManager)
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
            }
               
                
        }
        
    }
}

