//
//  HomeView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 23/02/2024.
// https://github.com/dadalar/SwiftUI-CardStackView

import SwiftUI
import CardStack
import FirebaseAuth

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationStack { 
            ZStack {
                VStack {
                    CardStack(direction: LeftRight.direction, data: viewModel.users, id: \.id) { user, direction in
                        if direction == .right { //if user swiped right, putting them in liked database
                            print("did swipe right \(user.id)")
                            if let matchingUser = viewModel.swipedOnUsers.first(where: { $0.userID == user.id && $0.isRight }) {
                                if let currentUser = sessionManager.currentUser {
                                    viewModel.createMessageThread(withUser: matchingUser.userID, matchingUser: user, currentUser: currentUser)
                                    viewModel.presentMatchingNotifiaction = true
                                }
                                
                            }
                            guard let userID = Auth.auth().currentUser?.uid else {
                                return
                            }
                            Task {
                               await viewModel.swiped(user: user, isRight: true, currentUserID: userID)
                            }
                        } else { //if user swiped left, putting in disliked database
                            guard let userID = Auth.auth().currentUser?.uid else {
                                return
                            }
                            Task {
                               await viewModel.swiped(user: user, isRight: false, currentUserID: userID)
                            }
                        }
                    } content: { user, _, _ in
                        CardView(user: user,cardDidTap: {
                            viewModel.selectedUser = user
                        })
                        .frame(height: UIScreen.main.bounds.height * 0.75)
                    }
                    .scaledToFit()
                    .frame( width: UIScreen.main.bounds.width * 0.9, alignment: .center)
                    Spacer()
                }
                .navigationDestination(item: $viewModel.selectedUser) { user in
                    CardDetailView(user: user)
                }
                if viewModel.isLoading { //loading feature
                    ZStack{
                        Color.loadingBackground.opacity(0.5).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
            .alert("You are a match!", isPresented: $viewModel.presentMatchingNotifiaction) {
                Button("Done") {
                    
                }
            } message: {
                Text("You have a new match, start a conversation in messages!")
            }

        }
        .onChange(of: sessionManager.sessionState, { oldValue, newValue in
            if newValue == .loggedOut { 
               
            }
            else {
                viewModel.requestLocation()
            }
        })
        .onAppear(perform: {
            viewModel.requestLocation()
           // User.createMockLocationUsers()
        })
        
       // .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    HomeView()
}
