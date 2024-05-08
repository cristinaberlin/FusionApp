//
//  LoginView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 19/12/2023.
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff 
//


import SwiftUI

/*
 This is where logs in app if they have an existing account
 */
struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    
    var body: some View {
        NavigationStack { //Navigation stack to move back and forth between pages
            VStack{
                //image
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height:160)
                    .padding(.vertical, 32)
                
                //form fields
                VStack(spacing:24 ) {
                    InputView(text: $viewModel.email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $viewModel.password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //sign in button
                Button {
                    Task{
                       let result = try await viewModel.signIn()
                        if result {
                            sessionManager.sessionState = .loggedIn
                        }
                    }
                    
                } label: {
                    HStack{
                        Text("SIGN IN")
                        Image(systemName: "arrow.right")
                    }

                }
                .buttonStyle(PrimaryButton())
                .disabled(!(viewModel.isEmailValid() && viewModel.isPasswordValid() ))
                .opacity((viewModel.isEmailValid() && viewModel.isPasswordValid() ) ? 1.0 : 0.5) //gives button faded look if the form isint valid
               
                
                Spacer()
                
                
                //creates a link between RegistrationView and LoginView
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    //sign up button
                    HStack (spacing: 4) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                    .font(.system(size: 14))
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"),
                      message: Text(viewModel.authError?.description ?? ""))
            }
            
            if viewModel.isLoading {
                CustomProgressView()
            }
         }
      }
   }

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionManager())
    }
}

