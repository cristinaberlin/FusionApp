//
//  CardDetailView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 29/02/2024.
//

import SwiftUI

/*
 The CardVetailView is when you tap to see more details of the user's profile card
 */
struct CardDetailView: View {
    let user: User
    var didLike: (_ isRight: Bool) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                AsyncImage(url: URL(string: user.avatar!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                } placeholder: {
                    Image("loading")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                .ignoresSafeArea()
                VStack {
                    Spacer()
                    HStack {
                        //This is the dislike button
                        Button(action: {
                            didLike(false)
                            dismiss()
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60)
                                    .shadow(color: Color.black.opacity(0.4), radius: 2)
                                Image(systemName: "xmark")
                                    .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(.red)
                            }
                        })
                        .padding(.leading, 45)
                   Spacer()
                    //This is the like button
                    Button(action: {
                        didLike(true)
                        dismiss()
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60)
                                .shadow(color: Color.black.opacity(0.4), radius: 2)
                            Image(systemName: "hand.thumbsup.fill")
                                 .font(.system(size: 25, weight: .bold))
                                 .foregroundStyle(.primaryTheme)
                        }
                         
                        })
                    .padding(.trailing, 45)
                    }
                }
                .offset(y: -45)
            }
            .frame(height: UIScreen.main.bounds.height * 0.5)
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
           .offset(y: -30) //changes the position of image
            .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    CardDetailView(user: User.mockUsers[0]) { isRight in
        
    }
}
