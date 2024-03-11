//
//  RegistrationView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 19/12/2023.
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff
// 

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var businessFieldSelection: BusinessFields = .marketing //default that is shown in picker if no prior selection
    @State private var password = ""
    @State private var confirmPassword = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
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
                
                InputView(text: $fullname,
                          title: "Full Name",
                          placeholder: "Enter your name")
                
                Picker("Business Picker", selection: $businessFieldSelection) {
                    ForEach(BusinessFields.allCases) { businessField in
                        Text(businessField.title)
                    }
                }
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: true)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty { //making sure both fields have text and as filling out form, If both fields are equal a checkmark will show if not an xmark will appear.
                        if password == confirmPassword {
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
                print("Sign User Up..") //prints in console
                Task{
                    try await viewModel.createUser(withEmail: email,
                                                   password: password,
                                                   fullname:fullname,
                                                   businessField: businessFieldSelection )
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
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5) //gives button faded look if the form isint valid
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

//MARK: - Authentication Form Protocol

extension RegistrationView: AuthenticationFormProtocol { //Authentication form protocol checks these password conditions
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthViewModel())
    }
}
