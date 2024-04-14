//
//  ResetPasswordView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 10/02/2024.
// User will be brought to this page for when they forget email and can input email in textbox

import SwiftUI

struct ResetPasswordView: View {
    @State private var email = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 140)
                .padding(.vertical, 32)
            
            
            InputView(text: $email,
                      title: "Email Address",
                      placeholder: "Enter the email associated with your account")
            .padding()
            
            Button {
                viewModel.sendResetPasswordLink(toEmail: email)
                dismiss()
            } label: {
                HStack {
                    Text("SEND RESET LINK")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding()
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "arrow.left")
                    
                    Text("Back to Login")
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
