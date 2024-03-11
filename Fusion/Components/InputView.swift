//
//  InputView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 19/12/2023.
//
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff

import SwiftUI

struct InputView: View {
    
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12) { //aligns text to left hand side
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField { //creates secure field for password
                SecureField(placeholder, text: $text)
                    .font(.system(size:14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size:14))
                
            }
            
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
}
