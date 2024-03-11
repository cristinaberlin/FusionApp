//
//  HomeViewModel.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 23/02/2024.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var users: [User] = User.mockUsers
    @Published var selectedUser: User?
    
}
