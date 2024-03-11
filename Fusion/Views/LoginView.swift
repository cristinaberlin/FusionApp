//
//  LoginView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 19/12/2023.
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff 
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack { //  Navigation stack to move back and forth between pages
            VStack{
                //image
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height:160)
                    .padding(.vertical, 32)
                
                //form fields
                VStack(spacing:24 ) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                    
                    NavigationLink { //Link for reset password view
                        ResetPasswordView()
                            .navigationBarHidden(true)
                    } label: {
                        Text("Forgot Password?")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.blue)
            
                    }
                    .padding(.bottom)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //sign in button
                Button {
                    Task{
                        try await  viewModel.signIn(withEmail: email, password: password)
                    }
                    
                } label: {
                    HStack{
                        Text("SIGN IN")
                        Image(systemName: "arrow.right")
                    }

                }
                .buttonStyle(PrimaryButton())
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5) //gives button faded look if the form isint valid
               
                
                Spacer()
                
                //sign up button
                
                NavigationLink { //creates a link between Registration and Login
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
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


//MARK: - Authentication Form Protocol

extension LoginView: AuthenticationFormProtocol { //Authentication form protocol checks these password conditions
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}

