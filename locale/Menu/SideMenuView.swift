//
//  SideMenuView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI


struct SideMenuView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @EnvironmentObject var onboardingVM : StripeOnboardingViewModel

    
    @Binding var showAccountMenu : Bool
    @Binding var showWithdrawal : Bool
    @Binding var showStripeOnboarding : Bool
    
    @State private var xOffset: CGFloat = -300 // Initial offset to start off-screen

    let menuItems : [String : String] = [
        "Profile" : "account-profile",
        "Settings" : "account-settings",
        "Privacy Policy" : "account-privacy",
        "Terms of Service" : "account-terms",
        "About Us" : "account-about",
        "Support" : "account-support",
        "Logout" : "account-logout"
    ]
    
    let menuItemOrder: [String] = [
        "Profile", "Settings", "Privacy Policy", "Terms of Service",
        "About Us", "Support", "Logout"
    ]
    
    @State var showProfile = false
    @State var showLogout = false
    
    
    @State var showImagePicker: Bool = false
    @State var selectedImage: UIImage?
    
    private func handleImageSelection(_ image: UIImage) {
         currentUser.uploadProfileImage(image) { result in
             switch result {
             case .success(let url):
                 currentUser.updateUserProfilePhotoURL(url) { result in
                     switch result {
                     case .success():
                         print("New Profile Image : \(currentUser.user.profilePhoto)")
                         print("User profile updated successfully")
                         currentUser.refreshID = UUID()
                     case .failure(let error):
                         print("Error updating user profile: \(error.localizedDescription)")
                     }
                 }
             case .failure(let error):
                 print("Error uploading image: \(error.localizedDescription)")
             }
         }
     }
    
    var profilePhoto = "profile-2"
    
    var body: some View {
        
        HStack {
            VStack {
                
                Button {
                    self.showImagePicker = true
                } label: {
                    ProfilePhotoOrInitial(profilePhoto: currentUser.user.profilePhoto, fullName: currentUser.user.name, radius: 80, fontSize: 24)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                }
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    if let selectedImage = self.selectedImage {
                        handleImageSelection(selectedImage)
                    }
                }) {
                    ImagePicker(image: self.$selectedImage)
                }
                .id(currentUser.refreshID)



                
                Spacer().frame(height : 20)
                
                //Account Buttons
                VStack {
                    
                    Button {
                        if currentUser.stripeOnboardingCompleted == nil || currentUser.stripeOnboardingCompleted == false {
                            showStripeOnboarding = true

                        } else {
                            showWithdrawal = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "dollarsign")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            
                            Text("Balance :")
                                .font(Font.custom("Avenir Next", size: 14))
                                .foregroundColor(.white)
                                .padding(.leading, 13)
                            Spacer()
                            
                            HStack {
                                Text("$\(String(format : "%.2f", currentUser.user.balance))")
                                    .font(Font.custom("Avenir Next", size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                            }
                            .frame( height : 30)
                            .background(.blue)
                            .cornerRadius(5)
                            .outerShadow()

                        }
                    }
                    .padding(.bottom, 32)
                    



                    ForEach(menuItemOrder, id: \.self) { key in

                        Button(action: {
                            if key == "Logout" {
                                self.showLogout.toggle()
                            } else if key == "Profile" {
                                self.showProfile = true
                                showAccountMenu = false
                            } else if key == "Settings" {
                                currentUser.showSettings = true
                            } else if key == "Terms of Service" {
                                currentUser.showTOS = true
                            }
                            
                            
                        }, label: {
                            HStack {
                                Image(menuItems[key] ?? "")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)

                                Text(key)
                                    .font(Font.custom("Avenir Next", size: 14))
                                    .foregroundColor(.white)
                                    .padding(.leading, 13)
                                Spacer()
                            }
                            .padding(.bottom, 32)
                        
                        })
                        .alert(isPresented: $showLogout) {
                            Alert(
                                title: Text("Are you sure you'd like to log out?"),
                                primaryButton: .destructive(Text("Log Out")) {
                                    currentUser.signOut()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                
                
                Spacer()
                
                Text("Version 1.0.0\n© 2024")
                  .font(
                    Font.custom("Avenir Next", size: 12)
                      .weight(.medium)
                  )
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
                
            }
            .frame(width: 220)
            .padding()
            .background(Color("background"))
            .edgesIgnoringSafeArea(.vertical)
            .onAppear {
                
                if !currentUser.stripeOnboardingCompleted {
                    onboardingVM.checkOnboardingStatus(userId: currentUser.currentUserID) { onboardingCompleted, error in
                        if let error = error {
                            // Handle error (e.g., show an error message)
                            print("Error checking onboarding status: \(error.localizedDescription)")
                            return
                        }
                        
                        if let onboardingCompleted = onboardingCompleted {
                            if onboardingCompleted {
                                // Navigate to WithdrawView
                                currentUser.stripeOnboardingCompleted = onboardingCompleted
                                
                                onboardingVM.fetchWithdrawalMethods(stripeAccountID: currentUser.stripeAccountID)

                            } else {
                                // Navigate to ConnectStripeView or open Stripe URL
                                currentUser.stripeOnboardingCompleted = false
                            }
                        } else {
                            // Handle unexpected result (e.g., show an error message)
                            print("Unexpected result from onboarding status check")
                        }
                    }
                }
            }
            
            
            Spacer()
        }
        
    }
}


struct MenuLoginState : View {
    var body: some View {
        VStack {
            
        }
    }
}

//#Preview {
//    SideMenuView( showAccountMenu: .constant(true))
//}
