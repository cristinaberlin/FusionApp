//
//  SettingsRowView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 18/02/2024.
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff

import SwiftUI

/*
 A reusable view used by the rows in the ProfileView
 */
struct SettingsRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.black)
            Spacer()
        }
    }
}

struct SettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowView(imageName: "paperplane.circle.fill",
                        title: "Test",
                        tintColor: Color(.systemBlue))
    }
}
