//
//  DeleteAccountView.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import Foundation
import SwiftUI


struct DeleteAccountView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    
    @State var currentPassword : String = ""
    
    
    @State var showErrorMessageModal = false
    @State var errorTitle = "Something went wrong"
    @State var errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues \n\n www.tutortree.com/support"
    
    
    func formatErrorMessage(errorDescription : String) {
        switch errorDescription {
        case "The password is invalid or the user does not have a password." :
            errorTitle = "Incorrect Password"
            errorMessage = "Your password is incorrect. Please try again"
            
        case "The email address is badly formatted." :
            errorTitle = "Invalid Email"
            errorMessage = "There's an issue with your email. Please ensure it's formatted correctly"
            
        default :
            errorTitle = "Something went wrong"
            errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues \n\n www.tutortree.com/support"
        }
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                VStack(alignment : .leading) {
                    HStack(spacing: 0) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                            generateHapticFeedback()

                        }) {
                            Image(systemName: "arrow.left")
                                .font(Font.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("text-bold"))
                                .opacity(0.7)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color("background-element"))
                                )
                                .outerShadow()
                        }
                        
                        Text("Delete Account")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color("text-bold"))
                        .padding(.horizontal)
                        
                        
                    }
                    .navigationTitle("")
                    .navigationBarHidden(true)
                    
                    
                    Text("Are you sure you'd like to delete your account? This is permanent and can't be undone.")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("text-bold"))
                        .padding(.top, 5)
                        .padding(.bottom)
                        .padding(.trailing)
                    
                    
                    VStack {
                        
                        VStack {
                            PasswordResetTextField(title : "Current Password", password: $currentPassword)
                            
                            Spacer().frame(height : 20)
   
                            HStack {
                                Spacer()
                                
                                Button {
                                    currentUser.deleteUserAccount(currentPassword: currentPassword) { success, errorMessage in
                                        if success {
                                            // Handle success (e.g., navigate back or show a success message)
                                            withAnimation {
                                                self.presentationMode.wrappedValue.dismiss()
                                                // Additional logic for post-account deletion, such as logging out the user or redirecting them to a welcome screen
                                            }
                                            
                                        } else {
                                            // Handle failure (e.g., show an error message)
                                            print(errorMessage?.localizedDescription ?? "")
                                            formatErrorMessage(errorDescription: errorMessage?.localizedDescription ?? "Unknown error")
                                            withAnimation {
                                                showErrorMessageModal = true
                                            }
                                        }
                                    }

                                } label: {
                                    
                                    HStack {
                                        
                                        Image(systemName : "trash.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("text-bold"))
                                        
                                        Text("Confirm")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color("text-bold"))

                                    }
                                    .frame(width : 150, height : 40)
                                    .background(.red)
                                    .cornerRadius(10)
                                    .outerShadow()
                                }
                            }
                            .padding(.top)
                        }
                        .padding(30)
                    }
                    .background {
                        Color("background-element")
                    }
                    .cornerRadius(15)
                    .outerShadow()
                    


                    
                    Spacer()

                }
                .padding()
                
                
            }
            .background {
                Color("background")
                    .edgesIgnoringSafeArea(.all)

            }
            .overlay(
                Color.black.opacity(showErrorMessageModal  ? 0.5 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showErrorMessageModal = false
                        }
                    }
            )
            
            
            VStack {
                Spacer()
                ErrorMessageModal(showErrorMessageModal: $showErrorMessageModal, title: errorTitle, message: errorMessage)
                    .centerGrowingModal(isPresented: showErrorMessageModal)
                Spacer()
            }
        }
    }
}
