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
        VStack{
            AsyncImage(url: URL(string: user.avatar!)) { phase in 
                // asynchronously loads and displays user's avatar url from database handling different loading states (empty, success, failure)
                switch phase {
                case .empty:
                    Image("loading")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                      
                       
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                       

                case .failure:
                    Image("loading")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        
                    
                @unknown default:
                    EmptyView()
                        .frame(width: 60, height: 60)
                }
            }
            .ignoresSafeArea()
            VStack(alignment: .leading){
                HStack {
                    Text(user.fullname)
                        .font(.system(size: 31,weight: .semibold)) //name
                    Spacer()
                }
                Text("\(user.businessField.title) \(user.company == nil ? "" : "@\(user.company!)" )")
                    .font(.system(size: 17)) //business field
                
                if let experience = user.experience { //user experience
                    Text(experience)
                        .font(.system(size: 15))
                        .padding(.top)
                }
                Spacer()
            }
            .padding()
            .frame(height: UIScreen.main.bounds.height * 0.4, alignment: .leading)
        }
    }
}

#Preview {
    CardDetailView(user: User.mockUsers[0])
}
