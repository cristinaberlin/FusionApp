//
//  RegistrationView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 19/12/2023.
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff
// 

import SwiftUI

/*
 This is where is the user will sign up if they do not have an account
 */
struct RegistrationView: View {
    @StateObject var viewModel = RegistrationViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
            //Logo image
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
                
                InputView(text: $viewModel.fullname,
                          title: "Full Name",
                          placeholder: "Enter your name")
                VStack (alignment: .leading, spacing: 12) { //aligns text to left hand side
                    HStack {
                        Text("Business Field")
                            .foregroundColor(Color(.darkGray))
                            .fontWeight(.semibold)
                            .font(.footnote)
                        Spacer()
                    }
                    HStack {
                        Picker("Business Picker", selection: $viewModel.businessFieldSelection) {
                            ForEach(BusinessFields.allCases) { businessField in
                                Text(businessField.title)
                                    .font(.system(size:14))
                            }
                        }
                        Spacer()
                    }
                    Divider()
                }
                
                InputView(text: $viewModel.password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $viewModel.confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: true)
                    
                    //making sure both fields have text and as filling out form, If both fields are equal a checkmark will show if not an xmark will appear.
                    if !viewModel.password.isEmpty && !viewModel.confirmPassword.isEmpty {
                        if viewModel.password == viewModel.confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                            
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            //sign in button
            Button {
                Task{
                    let result = try await viewModel.createUser()
                    if result {
                        sessionManager.sessionState = .loggedIn
                    }
                }
               
            } label: {
                HStack{
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, //any screen that has app the frame indents 32 pixels
                       height: 48 )
            }
            .background(Color(.systemBlue))
            .disabled(!(viewModel.isEmailValid() && viewModel.isPasswordValid() && viewModel.isFullnameValid()  ))
            .opacity((viewModel.isEmailValid() && viewModel.isPasswordValid() && viewModel.isFullnameValid()) ? 1.0 : 0.5) //gives button faded look if the form isint valid
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                       HStack (spacing: 4) {
                           Text("Already have an account?")
                           Text("Sign in")
                               .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                       }
                       .font(.system(size:14))
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(SessionManager())
    }
}
