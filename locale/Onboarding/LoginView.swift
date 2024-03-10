//
//  LoginView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var email : String = ""
    @State var password : String = ""

    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    
    @State var showErrorMessageModal = false
    @State var errorTitle = "Something went wrong"
    @State var errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues \n\n www.tutortree.com/support"
    
    @State var showPasswordResetModal = false
    
    func formatErrorMessage(errorDescription : String) {
        switch errorDescription {
        case "The password is invalid or the user does not have a password." :
            errorTitle = "Invalid Password"
            errorMessage = "Your password is incorrect. Please try again, or reset your password."
            
        case "The email address is badly formatted." :
            errorTitle = "Invalid Email"
            errorMessage = "There's an issue with your email. Please ensure it's formatted correctly"
            
        case "There is no user record corresponding to this identifier. The user may have been deleted." :
            errorTitle = "No Account Found"
            errorMessage = "There's no account matching that information. Please check your email and try again"
            
        default :
            errorTitle = "Something went wrong"
            errorMessage = "There seems to be an issue. Please try again "
        }
    }
    
    @State var navigateToHome = false
    
    
    var body: some View {
        
        ZStack {
            VStack(spacing : 0) {
                
                ZStack(alignment: .top) {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()

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
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Login")
                            .font(.system( size: 35 ))
                            .fontWeight(.bold)
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                


                Spacer().frame(height: 20)
                
                VStack {
                    VStack {
                        LoginEmailTextField( text: $email, emailErrorMessage: $emailErrorMessage)
                        SecureProfileTextField( password: $password, passwordErrorMessage: $passwordErrorMessage)
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
                    //Reset error states on tap
                    emailErrorMessage = ""
                    passwordErrorMessage = ""
                    
                    //Check for new error states
                    if email.isEmpty {
                        withAnimation {
                            emailErrorMessage = "Please enter your email"
                        }
                    } else if password.isEmpty {
                        withAnimation {
                            passwordErrorMessage = "Please enter your password"
                        }
                    } else {

                        Auth.auth().signIn(withEmail: email, password: password){ (authResult, error) in
                            if let error = error {
                                // Handle the error (e.g., incorrect OTP)
                                print("Error in authentication: \(error.localizedDescription)")
        
                                withAnimation {
                                    showErrorMessageModal = true
                                    print( error)
                                    formatErrorMessage(errorDescription: error.localizedDescription)
                                }
                                
                                return
                            }
    
                            print("Successfully authenticated user: \(Auth.auth().currentUser?.uid ?? "")")
//                            self.presentationMode.wrappedValue.dismiss()
                            navigateToHome = true

                        }
                    }
                } label: {

                    HStack {
                        Spacer()
                        Text("LOGIN")
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
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                }
                
                
                Button {
                    showPasswordResetModal = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Forgot password?")
                            .font(.system( size: 14))
                            .font(Font.system(size: 18))
                            .foregroundColor(Color("text-bold"))
                        Spacer()
                    }
                    .frame(height: 50)
                }

            }
            .padding()
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
                PasswordResetModal(showPasswordResetModal : $showPasswordResetModal)
                    .centerGrowingModal(isPresented: showPasswordResetModal)
                Spacer()
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




struct LoginEmailTextField : View {
    
    @Binding var text : String
    @Binding var emailErrorMessage : String
    
    @State var isEditing = false

    
    var body: some View {
        
        
        VStack(alignment : .leading) {

            Text("Email")
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
                    
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color("placeholder"))
                        .padding(.trailing, 5 )
                        .padding(.leading)
                    
                    
                    if text == "" && !isEditing {
                    
                        Text(verbatim : "name@example.com")
                            .font(.custom("SF Pro", size: 16))
                            .foregroundColor(emailErrorMessage != "" ? .red : Color("placeholder"))
                            .fontWeight(.bold)
                    }
                    
                    
                    Spacer()
                }
                
                TextField("", text: $text)
                    .frame(height : 40)
                    .foregroundColor(Color(.white))
                    .padding(.leading, 50)
                    .onTapGesture {
                        isEditing = true
                    }
                    .onChange(of: text) { oldValue, newValue in
                        self.text = newValue.lowercased()
                    }
            }
            
            if emailErrorMessage != "" {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14, weight : .semibold))
                        .foregroundColor(Color("text-bold"))
                    
                    Text(emailErrorMessage)
                        .font(.system(size: 14, weight : .semibold))
                        .foregroundColor(Color("text-bold"))

                }
                .padding(.leading)
                .transition(.opacity)
                .animation(.easeInOut, value: emailErrorMessage != "")

            }

        }
        .padding(.bottom, 30)
    }
}


struct SecureProfileTextField : View {

    @Binding var password : String
    @Binding var passwordErrorMessage : String
    
    var body: some View {
        
        VStack(alignment : .leading) {

            Text("Password")
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

struct LoginLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            ProgressView("Loading your account...")
                .padding(20)
                .background(Color.white)
                .cornerRadius(10)
        }
    }
}
#Preview {
    LoginView()
}
