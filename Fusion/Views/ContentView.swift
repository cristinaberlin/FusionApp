//
//  ContentView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 06/12/2023.
//
//Inspired by: https://www.youtube.com/watch?v=HJDCXdhQaP0&t=782s&ab_channel=CodeWithChris by CodeWithChris [Accessed 6 Dec]

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
       // ContentView().environmentObject(AuthViewModel())
        Group {
            if viewModel.userSession != nil {
                //If there is a user session the user will be sent to profile view if not they will be directed to login view
                
                ProfileView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
           .environmentObject(AuthViewModel()) // Injecting viewModel for previews
    }
}




