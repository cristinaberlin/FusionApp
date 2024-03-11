//
//  Extension+View.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 05/03/2024.
// Extension adds code to structure or class, This function is visable in every view in Fusion

import Foundation
import SwiftUI

#if canImport(UIKit) //responsible for dismissing keyboard in app when it is called
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
