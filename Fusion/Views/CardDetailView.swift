//
//  CardDetailView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 29/02/2024.
//

import SwiftUI

struct CardDetailView: View {
    let user: User
    var body: some View {
        VStack(spacing:0){
            AsyncImage(url: URL(string: user.avatar!)) { image in
                image
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                    .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image("loading")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0){
                HStack {
                    Text(user.fullname)
                        .font(.system(size: 31,weight: .semibold)) //name
                    Spacer()
                }
               HStack {
                   Text("\(user.businessField.title) \(user.company == nil ? "" : "@\(user.company!)" )")
                       .font(.system(size: 17)) //business field
                   Spacer()
                   Text(user.distanceAway ?? "0.8 km away") //capsule for km away
                       .font(.system(size: 14, design: .rounded))
                       .foregroundStyle(Color.textDarkGrey)
                       .fontWeight(.semibold)
                       .padding(.horizontal,10)
                       .padding(.vertical, 5)
                       .background(Color.textLightGrey.opacity(0.5))
                       .clipShape(Capsule())
               }
                if let experience = user.experience { //user experience
                    Text(experience)
                        .font(.system(size: 15))
                        .padding(.top)
                }
                Spacer()
            }
           .offset(y: -45) //changes the position of image
            .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    CardDetailView(user: User.mockUsers[0])
}
