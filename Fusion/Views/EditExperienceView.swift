//
//  EditExperienceView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 05/03/2024.
//

import SwiftUI

struct EditExperienceView: View {
    @StateObject var viewModel = EditExperienceViewModel()
    @Binding var currentExperience: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            TextEditor(text: $viewModel.experience)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.clear)
                        .stroke(Color.gray, lineWidth: 1)
                })
                .overlay(alignment: .bottomTrailing, content: { //adding in experience character limit
                    Text(String(viewModel.experience.count) + " / \(viewModel.characterLimit)" )
                        .foregroundStyle(Color(uiColor: UIColor.lightGray))
                        .padding(.trailing)
                        .padding(.bottom,5)
                })
                .disabled(viewModel.experience.count >= viewModel.characterLimit)
                .frame(height: 250)
                .padding(.horizontal)
          
            Button(action: {
                Task {
                   let result = await viewModel.saveExperience()
                    if result {
                        currentExperience = viewModel.experience
                     dismiss()
                    }
                }
                
            }, label: {
                Text("Save")
            })
            .buttonStyle(PrimaryButton())
        }
        .onAppear(perform: {
            viewModel.experience = currentExperience ?? ""
        })
    }
}

#Preview {
    EditExperienceView(currentExperience: .constant(""))
}
