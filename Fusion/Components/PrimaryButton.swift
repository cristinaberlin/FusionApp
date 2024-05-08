//
//  PrimaryButton.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 22/02/2024.
//

import Foundation
import SwiftUI

/*
 This is a reusable button
 */
struct PrimaryButton: ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: UIScreen.main.bounds.width - 32, //any screen that has app the frame indents 32 pixels
                   height: 48 )
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top, 24)
    }
    
    
    
}
