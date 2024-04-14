//
//  MessagingView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 1/04/2024.
//

import SwiftUI

struct MessagingView: View {
    @StateObject var viewModel = MessagingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.messageThreads) { messageThread in
                    MessageRowView(messageThread: messageThread)
                }
            }
            .navigationTitle("Messages")
        }
        .onAppear(perform: {
            viewModel.getThreads()
        })
    }
}

#Preview {
    MessagingView()
}
