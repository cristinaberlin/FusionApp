//
//  ProfileView.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 20/12/2023.
//  Inspired by: https://www.youtube.com/watch?v=QJHmhLGv-_0&ab_channel=AppStuffc by App Stuff

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var imageLoaderViewModel = ImageLoaderViewModel()
    @State private var businessFieldSelection: BusinessFields = .marketing //default that is shown in picker if no prior selection
    
    var body: some View {
        NavigationStack { //allows user to navigate between pages
            ZStack {
                VStack {
                    if let user = authViewModel.currentUser {
                        List {
                            Section { //first section, displays initials, image, name and email
                                HStack {
                                    AsyncImage(url: viewModel.avatar) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle()).frame(width:72, height:72)
                                    } placeholder: {
                                        Text(user.initials)
                                            .font(.title)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 72, height: 72)
                                            .background(Color(.systemGray3))
                                            .clipShape(Circle())
                                    }
                                    .onTapGesture {
                                        print("did tap")
                                        viewModel.showImageOptions = true
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.fullname)
                                            .fontWeight(.semibold)
                                            .padding(.top, 4)
                                        
                                        Text(user.email)
                                            .font(.footnote)
                                            .accentColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            Section("Bio") { //section for bio
                                Button {
                                    viewModel.presentEditBio = true
                                } label: {
                                    Text(viewModel.bio ?? "You do not have a bio yet")
                                }

                            }
                            Section("Business Field") { //User can choose from business fields
                                Picker("Business Field", selection: $businessFieldSelection) {
                                    ForEach(BusinessFields.allCases) { businessField in
                                        Text(businessField.title)
                                    }
                                }
                               // .pickerStyle(.wheel)
                            }
                            
                            Section("Company") { //User can add company they work at
                                VStack {
                                    TextField("Add Company Here", text: $viewModel.company)
                                        .toolbar {
                                            ToolbarItemGroup(placement: .keyboard) {
                                                Spacer()
                                                Button {
                                                    viewModel.updateCompany()
                                                } label: {
                                                    
                                                    Text("Save")
                                                }

                                            }
                                        }
                                }
                            }
                            Section("Experience") { //section for experience
                                Button {
                                    viewModel.presentEditExperience = true
                                } label: {
                                    Text(viewModel.experience ?? "You have not yet written your experience")
                                }

                            }
                            
                            Section("General") {
                                HStack {
                                    SettingsRowView(imageName: "gear.circle",
                                                    title: "Version",
                                                    tintColor: Color(.systemGray))
                                    
                                    Spacer()
                                    
                                    Text("1.0.0")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            Section("Account") { //buttons for signing out and deleting account
                                Button {
                                    authViewModel.signout()
                                } label: {
                                    SettingsRowView(imageName: "arrow.left.circle.fill",
                                                    title: "Sign Out",
                                                    tintColor: Color(.systemRed))
                                }
                                
                                Button {
                                    Task {
                                        try await authViewModel.deleteAccount()
                                    }
                                } label: {
                                    SettingsRowView(imageName: "xmark.circle.fill",
                                                    title: "Delete Account",
                                                    tintColor: Color(.systemRed))
                                }
                            }
                        }
                    }
                    
                    
                }
               
                if authViewModel.isLoading {
                    CustomProgressView()
                }
                if viewModel.uploadIsActive {
                    ZStack{
                        Color.black.opacity(0.4)
                        VStack{
                            ProgressView("Uploading an Image", value: viewModel.uploadProgress, total: 1)
                                .foregroundStyle(.white)
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.horizontal)
                        }
                    }
                    .ignoresSafeArea() 
                }
            }
            .onTapGesture(perform: { //dismisses keyboard
              hideKeyboard()
            })
            .navigationTitle("Profile") //Shown at the top of the screen
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $viewModel.presentEditBio, destination: {
                EditBioView(currentBio: $viewModel.bio)
            })
            .navigationDestination(isPresented: $viewModel.presentEditExperience, destination: {
                EditExperienceView(currentExperience: $viewModel.experience)
            })
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: { //error handling in case image cant upload an error will appear
                Button {
                    
                } label: {
                    Text("Ok")
                }

            }, message: {
                Text(viewModel.alertMessage)
            })
            .onChange(of: authViewModel.currentUser, { oldValue, newValue in
                if let user = newValue
                {
                    if let avatarurl = user.avatar{
                        viewModel.avatar = URL(string: avatarurl)
                    }
                    if let bio = user.bio {
                        viewModel.bio = bio
                    }
                }
            })
            .onAppear(perform: {
                if let avatarurl = authViewModel.currentUser?.avatar{
                    viewModel.avatar = URL(string: avatarurl)
                }
                if let bio = authViewModel.currentUser?.bio {
                    viewModel.bio = bio
                }
                if let experience = authViewModel.currentUser?.experience {
                    viewModel.experience = experience
                }
            })
            .confirmationDialog("Select an image to upload", isPresented: $viewModel.showImageOptions, actions: {
                Button {
                    viewModel.showCamera = true //user can take a picture with camera
                } label: {
                    Text("Take a Picture")
                }
                Button {
                    viewModel.showLibrary = true //user can upload an image
                } label: {
                    Text("Upload from Library")
                    
                }
               
            })
            .fullScreenCover(isPresented: $viewModel.showCamera , content: {
                CameraPicker(sourceType: .camera) { image in
                    viewModel.upload(image: image)
                }
            })
            
            .onChange(of: imageLoaderViewModel.imageToUpload, { oldValue, newValue in
            if let value = newValue {
                viewModel.upload(image: value)
            }
            })
            
            .photosPicker(isPresented: $viewModel.showLibrary, selection: $imageLoaderViewModel.imageSelection, matching: .images, photoLibrary: .shared())
            
            .onChange(of: businessFieldSelection,
                      { oldValue, newValue in
                if let user = authViewModel.currentUser {
                    guard user.businessField != newValue else {
                        return
                    }
                    viewModel.save(businessField: newValue)
                }
            })
            
            .onChange(of: authViewModel.currentUser, { oldValue, newValue in //monitors for new change, remembers it and passes info through user
                if newValue != nil {
                    businessFieldSelection = newValue!.businessField
                }
        })
        }
        .onAppear {
            if let company = authViewModel.currentUser?.company {
                viewModel.company = company
            }
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}

  
  
