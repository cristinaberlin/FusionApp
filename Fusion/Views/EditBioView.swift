//
//  EditBioView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 22/02/2024.
// When user clicks into bio to edit they will be brought to this page where user can input bio
// Add character limit !

import SwiftUI

struct EditBioView: View {
    
    @StateObject var viewModel = EditBioViewModel()
    @Binding var currentBio: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            TextEditor(text: $viewModel.bio)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.clear)
                        .stroke(Color.gray, lineWidth: 1)
                })
                .overlay(alignment: .bottomTrailing, content: { //adding in bio character limit
                    Text(String(viewModel.bio.count) + " / \(viewModel.characterLimit)" )
                        .foregroundStyle(Color(uiColor: UIColor.lightGray))
                        .padding(.trailing)
                        .padding(.bottom,5)
                })
                .disabled(viewModel.bio.count >= viewModel.characterLimit)
                .frame(height: 250)
                .padding(.horizontal)
          
            Button(action: {
                Task {
                   let result = await viewModel.saveBio()
                    if result {
                        currentBio = viewModel.bio
                     dismiss()
                    }
                }
                
            }, label: {
                Text("Save")
            })
            .buttonStyle(PrimaryButton())
        }
        .onAppear(perform: {
            viewModel.bio = currentBio ?? ""
        })
    }
}

#Preview {
    EditBioView(currentBio: .constant("Test"))
}
