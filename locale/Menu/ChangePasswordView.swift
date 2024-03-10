//
//  SwiftUIView.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import SwiftUI


struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    
    @State var currentPassword : String = ""
    @State var newPassword : String = ""
    @State var confirmNewPassword : String = ""
    
    @State var didChangePassword : Bool = false
    
    @State var showErrorMessageModal = false
    @State var errorTitle = "Something went wrong"
    @State var errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues"
    
    @State var showPasswordResetModal = false
    
    func formatErrorMessage(errorDescription : String) {
        switch errorDescription {
        case "The password is invalid or the user does not have a password." :
            errorTitle = "Incorrect Password"
            errorMessage = "Your current password is incorrect. Please try again"
            
        case "The email address is badly formatted." :
            errorTitle = "Invalid Email"
            errorMessage = "There's an issue with your email. Please ensure it's formatted correctly"
            
        default :
            errorTitle = "Something went wrong"
            errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues"
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
                        
                        Text("Change Password")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color("text-bold"))
                        .padding(.horizontal)
                        
                        
                    }
                    .navigationTitle("")
                    .navigationBarHidden(true)
                    
                    
                    if didChangePassword {
                        HStack {
                            Spacer()
                            
                            VStack {
                                VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color("text-bold"))
                                        .padding(.bottom, 10)
                                    
                                    Text("Password Updated")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color("text-bold"))
                                        .padding(.bottom)
                                    
                                    VStack {
                                        Text("You can now use your new password to log in. \n ")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color("text-bold"))
                                            .multilineTextAlignment(.center)
                                    
                                    }
                                }
                                .padding(30)
                            }
                            .background {
                                Color("background-element")
                            }
                            .cornerRadius(15)
                            .outerShadow()
                            .transition(.opacity)
                            .animation(.easeInOut, value: didChangePassword)
                            .frame(height : 400)
                            
                            Spacer()
                        }
                    } else {
                        
                        VStack {
                            VStack {
                                PasswordResetTextField(title : "Current Password", password: $currentPassword)
                                
                                Spacer().frame(height : 20)
                                
                                PasswordResetTextField(title : "New Password", password: $newPassword)
                                
                                PasswordResetTextField(title : "Confirm Password", password: $confirmNewPassword)
                                
                                
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        if newPassword != confirmNewPassword {
                                            withAnimation {
                                                showErrorMessageModal = true
                                                errorTitle = "Mismatching password"
                                                errorMessage = "Your new passwords don't match. Please try again"
                                            }
                                        } else {
                                            currentUser.reauthenticateAndUpdatePassword(currentPassword: currentPassword, newPassword: newPassword) { success, errorMessage in
                                                if success {
                                                    // Handle success (e.g., show a success message or indicator)
                                                    withAnimation {
                                                        didChangePassword = true
                                                    }
                                                } else {
                                                    // Handle failure (e.g., show an error message)
                                                    print("Failed to update password: \(errorMessage ?? "Unknown error")")
                                                    withAnimation {
                                                        showErrorMessageModal = true
                                                        formatErrorMessage(errorDescription: errorMessage ?? "Unknown error")
                                                    }
                                                }
                                            }
                                        }

                                    } label: {
                                        
                                        HStack {
                                            
                                            Image(systemName : "key.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color("text-bold"))
                                            
                                            Text("Confirm")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color("text-bold"))

                                        }
                                        .frame(width : 150, height : 40)
                                        .background(Color("background-element"))
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
                        
                    }
                    


                    
                    Spacer()
                }
                .padding()
                
                
            }
            .background {
                Color("background")
                    .edgesIgnoringSafeArea(.all)

            }
            .overlay(
                Color.black.opacity(showErrorMessageModal || showPasswordResetModal ? 0.5 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showPasswordResetModal = false
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




struct PasswordResetTextField : View {
    var title : String
    @Binding var password : String
    
    var body: some View {
        
        VStack(alignment : .leading) {

            Text(title)
                .font(.system( size: 14 ))
                .fontWeight(.medium)
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("background-textfield")
                        .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                        .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                    )
                    .frame(height : 50)
                    .cornerRadius(15)

                
                HStack {
                    
                    Image(systemName: "key.fill")
                        .foregroundColor(Color("placeholder"))
                        .padding(.trailing, 5 )
                        .padding(.leading)
                    
                    Spacer()
                }
                
                SecureField("*********", text: $password, prompt: Text("*********"))
                    .frame(height : 50)
                    .foregroundColor( Color("text-bold") )
                    .padding(.leading, 40)
            }
            
        }
        .padding(.bottom, 20)

    }
}

