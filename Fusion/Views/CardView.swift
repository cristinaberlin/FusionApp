//
//  CardView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 23/02/2024.
// I used a library for the cards https://github.com/dadalar/SwiftUI-CardStackView

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CardView: View, Identifiable {
    let id: UUID = UUID()
    let user: User
    let defaultAvatar = "https://firebasestorage.googleapis.com:443/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2F6b1a27b6_4f93_4fec_9d6b_b028297155de.jpeg?alt=media&token=20a33311-4fee-4e4b-b9f3-22f4f7611fc2"
    var cardDidTap: () -> Void
    
    @State private var isLoading = false
    
    var body: some View {
        
        ZStack {
            Color.modeBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    VStack {
                        AsyncImage(url: URL(string: user.avatar ?? defaultAvatar)) { phase in
                            switch phase {
                            case .empty:
                                Image("loading")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .cornerRadius(20)
                                    .frame(width: 350)
                                    .frame(maxHeight: .infinity)
                                    .clipped()
                                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .cornerRadius(20)
                                    .frame(width: 355)
                                    .frame(maxHeight: .infinity)
                                    .clipped()
                                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                                
                            case .failure: //if image doesnt load, it shows image loading
                                Image("loading")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .cornerRadius(20)
                                    .frame(width: 350,height: 280)
                                    .clipped()
                                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                                
                            @unknown default:
                                EmptyView()
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .onTapGesture(perform: {
                          cardDidTap()
                            
                        })
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack(alignment: .leading, spacing: 5) {
                        Spacer()
                        Text("\(user.fullname)")
                            .font(.system(size: 20, design: .rounded))
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .padding(.horizontal, 15)
                        HStack {
                            Text(user.businessField.title)
                                .lineLimit(1)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .padding(.horizontal, 15)
                            
                            Spacer()
                        }
                        HStack {
                            Text(user.bio ?? "")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.white)
                                .fontWeight(.regular)
                                .padding(.horizontal, 15)
                            Spacer()
                            Text(user.distanceAway ?? "") 
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(Color.textLightGrey)
                                .fontWeight(.semibold)
                                .padding(.trailing, 15)
                        }
                    }
                    .padding(.bottom)
                    .frame(width: UIScreen.main.bounds.width * 0.9) //size of card
                    
                }//MARK: - End of ZStack
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .frame(maxHeight: .infinity)
                .shadow(radius: 1.5)
                
                VStack {
                    Spacer()
                    HStack {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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
                        
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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
                    Spacer()
                }
                .background(content: {
                    Color.background
                })
                .frame(height: 100)
                .frame(width: UIScreen.main.bounds.width * 0.9)
            }
            .cornerRadius(20)
            .background(
                Rectangle()
                    .fill(Color.background)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.6), radius: 4.5,x: 0,y: 0)
            )
            .frame(maxHeight: .infinity)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(user: User.mockUsers[0]) {
        }
    }
}
