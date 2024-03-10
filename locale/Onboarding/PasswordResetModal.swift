//
//  PasswordResetModal.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI



struct PasswordResetModal : View {
    @Binding var showPasswordResetModal : Bool
    
    @State var email : String = ""
    @State var isEditing = false
    @State var emailError = false
    @State var emailSent = false
    
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing : 0) {
            HStack {
                Button {
                    showPasswordResetModal = false

                } label: {
                    Image(systemName : "xmark")
                        .foregroundColor(Color("text-bold"))
                        .opacity(0.7)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("background-element"))
                        )
                        .outerShadow()
                }
                Spacer()
                
                if !emailSent {
                    Text("Forgot Password?")
                        .font(.system(size: 18, weight : .bold))
                        .foregroundColor(Color("text-bold"))
                        .offset(x : -10)
                }

                Spacer()

            }
            .padding()
            
            if emailSent {
                VStack(alignment: .center, spacing : 0) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color("text-bold"))
                        .padding(.bottom, 10)
                    
                    Text("Successfully Sent!")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("text-bold"))
                    
                    VStack {
                        Text("You'll receive instructions shortly. If you need further assistance please contact support at the link below\n ")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("text-bold"))
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            openURL(URL(string: "https://www.tutortree.com/support")!)
                        }) {
                            Text(verbatim : "https://www.tutortree.com/support")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("text-bold"))
                        }
                        
                    }
                    .padding()
                    .padding(.bottom)

                }
                .transition(.opacity)
                .animation(.easeInOut, value: emailSent)
                
                
            } else {
                Text("Enter your email below and we'll send you a link to reset your password.")
                    .font(.system(size: 14, weight : .medium))
                    .foregroundColor(Color("text-bold"))
                    .padding(.horizontal)
                
                
                HStack {
                    Spacer()
                    
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
                            
                            
                            if email == "" && !isEditing {
                            
                                Text(verbatim : "name@example.com")
                                    .font(.custom("SF Pro", size: 16))
                                    .foregroundColor(emailError ? .red : Color("placeholder"))
                                    .fontWeight(.bold)
                            }
                            
                            
                            Spacer()
                        }
                        
                        TextField("", text: $email)
                            .frame(height : 40)
                            .foregroundColor(Color("text-bold"))
                            .padding(.leading, 50)
                            .onTapGesture {
                                isEditing = true
                            }
                            .onChange(of: email) { oldValue, newValue in
                                self.email = newValue.lowercased()
                            }
                    }
                    
                    Spacer()

                }
                .padding()

                
                HStack(spacing : 15) {
                    
                    
                    Button {
                        if email == "" {
                            emailError = true
                        } else {
//                            Auth.auth().sendPasswordReset(withEmail: email) { error in
//
//                                if let error = error {
//                                    print(error.localizedDescription)
//                                }
//                                
//                                withAnimation {
//                                    emailSent = true
//                                    print("Password reset email sent to : \(email)")
//                                }
//                            }
                        }
                    } label: {
                        HStack(spacing : 0) {
                            
                            Text("Send Password Reset")
                                .font(.system(size : 16, weight : .bold))
                                .foregroundColor(.white)
                        }
                        .frame( width : 200, height : 40)
                        .background(.blue)
                        .cornerRadius(10)
    //                    .shadow(color: Color("shadow-black"), radius: 3, x: -2, y: -2)
                        .shadow(color: Color("shadow-black"), radius: 3, x: 2, y: 2)
                    }

                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }

        }
        .frame(width : 350)
        .background(Color("background"))
        .cornerRadius(15)
        .outerShadow()
    }
}

//#Preview {
//    PasswordResetModal()
//}
