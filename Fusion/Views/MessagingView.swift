//
//  MessagingView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 1/04/2024.
//

import SwiftUI

struct MessagingView: View {
    @StateObject var viewModel = MessagingViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.messageThreads) { messageThread in
                    MessageRowView(messageThread: messageThread)
                }
            }
            .navigationTitle("Messages")
        }
        .onChange(of: sessionManager.sessionState, { oldValue, newValue in
            if newValue == .loggedOut { //if user logs out, the listener is turned off and when they log back in the same listener kicks in
                viewModel.listenerRegistration?.remove()
                viewModel.listenerRegistration = nil
            }
            else {
                viewModel.getThreads()
            }
                
                
        })
        .onAppear(perform: {
            viewModel.getThreads()
        })
    }
}

#Preview {
    MessagingView()
}
