//
//  ChatView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 15/04/2024.
//

import SwiftUI

struct ChatView: View {
    
    @State var chatText = ""
    
    private var ChatBottomBar: some View {
        HStack{
            ZStack {
             TextEditor(text: $chatText)
            //        .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40 )
            Button(action: {}, label: {
                Text("Send")
                    .foregroundStyle(Color.white)
            })
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader(content: { proxy in
                VStack{
                    
                }
            })
        }
        .background(Color(.secondarySystemBackground))
        .safeAreaInset(edge: .bottom) {
          ChatBottomBar
        }
    }
}

#Preview {
    ChatView()
}
