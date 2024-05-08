//
//  CustomLoadingView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 18/02/2024.
//
//

import SwiftUI

/*
 This CustomLoadingView is a reusable view that is shown everytime a loading screen appears in the app
 */
struct CustomProgressView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .accentColor(.white)
            .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
            .frame(width: 80, height: 80)
            .background(Color(.systemGray4))
            .cornerRadius(20)
    }
}

struct CustomProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CustomProgressView()
    }
}
