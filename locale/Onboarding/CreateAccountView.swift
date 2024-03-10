//
//  CreateView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct CreateAccountView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    @State var confirmPasswordErrorMessage = ""

    @State var showErrorMessageModal = false
    @State var errorTitle = "Something went wrong"
    @State var errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues"
    
    @State private var isLoading: Bool = false
    @State private var navigateToHome: Bool = false

    private func createAccount() {
        withAnimation {
            //Reset errors every attempt
            emailErrorMessage = ""
            passwordErrorMessage = ""
            confirmPasswordErrorMessage = ""
            
            if email == "" {
                emailErrorMessage = "Please enter an email"
                
            } else if password.isEmpty {
                passwordErrorMessage = "Please choose a password"
                
            } else if confirmPassword.isEmpty {
                confirmPasswordErrorMessage = "Please confirm your password"
                
            } else if password != confirmPassword {
                confirmPasswordErrorMessage = "Your passwords don't match"
                
            } else {
                isLoading = true
                
                currentUser.createUser(email: email, password: password) { success, errorMessage in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Ensure minimum 2 seconds loading
                        isLoading = false
                        if success {
                            navigateToHome = true
                        } else {
                            showErrorMessageModal = true
                            formatErrorMessage(errorDescription: errorMessage)
                        }
                    }
                }
            }
        }

    }
    
    
    func formatErrorMessage(errorDescription : String) {
        switch errorDescription {
        case "The email address is already in use by another account." :
            errorTitle = "Email in use"
            errorMessage = "This email is already being used by another account. If this is you, please try logging in instead"
            
        case "The email address is badly formatted." :
            errorTitle = "Invalid Email"
            errorMessage = "There's an issue with your email. Please ensure it's formatted correctly"
            
        case "The password must be 6 characters long or more." :
            errorTitle = "Insecure Password"
            errorMessage = "Please choose a password with 6 characters or more."
            
        default :
            errorTitle = "Something went wrong"
            errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues \n\n www.tutortree.com/support"
        }
    }
    
    var body: some View {
        
        ZStack {
            Color("background")
                .edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing : 0) {
                
                ZStack {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()

                        }) {
                            Image(systemName: "arrow.left")
                                .font(Font.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(.white))
                                .opacity(0.7)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color("background-element"))
                                )
                                .outerShadow()
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Create Account")
                            .font(.system( size: 35 ))
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 30)
                .navigationTitle("")
                .navigationBarHidden(true)

                Spacer().frame(height: 20)
                
                
                
                VStack {
                    VStack {
                        LoginEmailTextField(text: $email, emailErrorMessage: $emailErrorMessage)
                        CreateAccountPasswordField( password: $password, passwordErrorMessage: $passwordErrorMessage, prompt: "Password")
                        CreateAccountPasswordField( password: $confirmPassword, passwordErrorMessage: $confirmPasswordErrorMessage, prompt : "Confirm Password")
                    }
                    .padding(30)

                }
                .background {
                    Color("background-element")
                }
                .cornerRadius(15)
                .outerShadow()

                
                Spacer()
                
                Button {
                    self.createAccount()
                } label: {
                    HStack {
                        Spacer()
                        Text("CREATE ACCOUNT")
                            .font(.system(size: 14, weight : .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(height : 50)
                    .background {
                        Color.blue
                    }
                    .cornerRadius(10)
                    .outerShadow()

                }
                .padding(.bottom, 20)
                .padding(.horizontal)
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                }

            }
            .padding()
            .overlay {
                if isLoading {
                    LoadingView()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.black.opacity(showErrorMessageModal ? 0.5 : 0)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showErrorMessageModal = false
                            }
                        }
                }
            }
            
            VStack {
                Spacer()
                ErrorMessageModal(showErrorMessageModal: $showErrorMessageModal, title: errorTitle, message: errorMessage)
                    .centerGrowingModal(isPresented: showErrorMessageModal)
                Spacer()
            }
        }
    }
}



struct CreateAccountPasswordField : View {

    @Binding var password : String
    @Binding var passwordErrorMessage : String
    var prompt : String
    
    var body: some View {
        
        VStack(alignment : .leading) {

            Text(prompt)
                .font(.system( size: 18 ))
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
                    .frame(height : 40)
                    .foregroundColor( Color("text-bold") )
                    .padding(.leading, 50)
            }
            
            if passwordErrorMessage != "" {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14, weight : .semibold))
                        .foregroundColor(Color("text-bold"))
                    
                    Text(passwordErrorMessage)
                        .font(.system(size: 14, weight : .semibold))
                        .foregroundColor(Color("text-bold"))

                }
                .padding(.leading)
                .transition(.opacity)
                .animation(.easeInOut, value: passwordErrorMessage != "")

            }
        }
        .padding(.bottom, 30)

    }
}

struct LoadingView: View {
    @State private var isAnimating = false

    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                
                Text("Creating your account..")
                    .font(.system( size: 18, weight : .semibold ))
                    .foregroundColor(Color("text-bold"))
                    .padding(.horizontal)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                
            }
            .frame(width : 250, height : 250)
            .background(Color("background"))
            .cornerRadius(15)
            .outerShadow()
        }
    }
}


#Preview {
    CreateAccountView()
}
