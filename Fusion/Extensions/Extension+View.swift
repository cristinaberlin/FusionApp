//
//  Extension+View.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 05/03/2024.
//

import Foundation
import SwiftUI

/*
 The Extension+View provides a way to hide a user's keyboard
 */
#if canImport(UIKit) //responsible for dismissing keyboard in app when it is called
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
