//
//  HomeView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 23/02/2024.
//  Inspired by: https://github.com/dadalar/SwiftUI-CardStackView
//  Inspired by: https://www.kodeco.com/34652639-building-a-recommendation-app-with-create-ml-in-swiftui

import SwiftUI
import FirebaseAuth

/*
 The HomeView is displays for the cards of users who are in close proximity to them (500km radius)
 I use the Library card stack to display the swipeable cards https://github.com/dadalar/SwiftUI-CardStackView
 A recommendation algorithm is used that learns the user's preferences from the user's swipes https://www.kodeco.com/34652639-building-a-recommendation-app-with-create-ml-in-swiftui
 */
struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    @State var swipeAction: SwipeAction = SwipeAction(isRight: false)
    let spacing: CGFloat = 10
    let padding: CGFloat = 10
    
    var itemWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return (screenWidth - (padding * 2) - (spacing * 2)) / 3
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // This is the section that shows the recommendations from the recommender algorithm
                    // It is designed to show just 3 recommendations at a time, based on user's swipes they update
                    if viewModel.recommendations.count >= 3 {
                        //below are the three boxes that show the recommendations from the recommendations algorithm
                        HStack(spacing: spacing) {
                            ForEach(0...2, id: \.self) { item in
                                //This is a button, when tapped this takes the user to the details of the recommended user
                                Button(action: {
                                    viewModel.selectedUser = viewModel.recommendations[item]
                                }, label: {
                                    //I used an async image because the image is from a remote URL https://www.swiftanytime.com/blog/asyncimage-in-swiftui
                                    AsyncImage(url: URL(string: viewModel.recommendations[item].avatar ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: itemWidth, height: itemWidth)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    } placeholder: {
                                        ZStack {
                                            Color.textLightGrey
                                                .frame(width: itemWidth, height: itemWidth)
                                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                            //adds in a progress spinner that tells user something is loading
                                            ProgressView()
                                            
                                        }
                                    }
                                })
                            }
                        }
                        .padding(.horizontal, padding)
                    }
                    //This is the card stack library that displays the swipeable cards
                    CardStack(direction: LeftRight.direction, data: viewModel.users, id: \.id, swipeAction: $swipeAction) { user, direction in
                        //Adjusts recommendation based on swipe direction https://www.kodeco.com/34652639-building-a-recommendation-app-with-create-ml-in-swiftui
                        viewModel.makeRecommendation(user: user, isLiked: direction == .right)
                        viewModel.swipedUsers.append(user)
                        if direction == .right { //if user swiped right, putting them in liked database
                        //If you swipe right this attempts to see if other user also swiped right and creates a message thread
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
                                //This keeps a record of all the user's swipes to the right
                               await viewModel.swiped(user: user, isRight: true, currentUserID: userID)
                            }
                        } else { //if user swiped left, putting in disliked section in firebase database
                            guard let userID = Auth.auth().currentUser?.uid else {
                                return
                            }
                            Task {
                                //This keeps a record of all the user's swipes to the left
                               await viewModel.swiped(user: user, isRight: false, currentUserID: userID)
                            }
                        }
                    } content: { user, _, _ in
                        //The card stack library requires that I provide the design of the swipable card to show
                        CardDisplayView(user: user, cardDidTap: {
                            viewModel.selectedUser = user
                        }, didLike: { isRight in
                            //This responds to whether the user tapped the like or dislike button
                            swipeAction = SwipeAction(isRight: isRight)
                            viewModel.makeRecommendation(user: user, isLiked: isRight)
                            viewModel.swipedUsers.append(user)
                            //if user swiped right, putting them in liked database
                            if isRight {
                            //if user swipes right this attempts to see if other user also swiped right and creates a message a thread
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
                        })
                        .frame(height: (UIScreen.main.bounds.height * 0.75) - (viewModel.recommendations.count >= 3 ? itemWidth : 0))
                    }
                    .frame( width: UIScreen.main.bounds.width * 0.9, alignment: .center)
                    .padding(.top, itemWidth / 2)
                    Spacer()
                }
                
                .navigationDestination(item: $viewModel.selectedUser) { user in
                    CardDetailView(user: user) { isRight in
                        swipeAction = SwipeAction(isRight: isRight)
                        viewModel.makeRecommendation(user: user, isLiked: isRight)
                        viewModel.swipedUsers.append(user)
                        if isRight { //if user swiped right, putting them in liked database
                        // if you swipe right this attempts to see if other user also swiped right and creates a message a thread
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
                    }
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
    
    func responseToSwipe(isRight: Bool) {
        
    }
    
}

//#Preview {
//    HomeView()
//}
