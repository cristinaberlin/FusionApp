//
//  HomeView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 23/02/2024.
// https://github.com/dadalar/SwiftUI-CardStackView

import SwiftUI
import CardStack

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack { 
            VStack {
                CardStack(direction: LeftRight.direction, data: viewModel.users, id: \.id) { card, direction in
                    
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
        }
       // .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    HomeView()
}
