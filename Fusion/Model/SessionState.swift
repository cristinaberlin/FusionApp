//
//  SessionState.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 29/03/2024.
//
//  

import Foundation

/*
 This model describes all the possible session states
 A user is either logged in or logged out
 */
enum SessionState {
    case loggedOut, loggedIn //two states for the session
}
