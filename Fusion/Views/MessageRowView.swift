//
//  MessageRowView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 14/04/2024.
//

import SwiftUI

/*
 This is a reusable view to display a message thread row in the messaging view
 */
struct MessageRowView: View {
    let messageThread: MessageThread
    var body: some View {
        HStack {
            AsyncImage(url: messageThread.avatar) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle()).frame(width:45, height:45)
            } placeholder: {
                Text(messageThread.username.prefix(3))
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(Color(.systemGray3))
                    .clipShape(Circle())
            }
            Text(messageThread.username)
            Spacer()
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    MessageRowView(user: User(id: UUID().uuidString, fullname: "Cristina Berlinschi", email: "cris21@gmail.com", businessField: .it, company: nil, experience: nil, bio: nil , avatar: "https://firebasestorage.googleapis.com:443/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2F6b1a27b6_4f93_4fec_9d6b_b028297155de.jpeg?alt=media&token=20a33311-4fee-4e4b-b9f3-22f4f7611fc2"))
//}
