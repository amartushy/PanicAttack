//
//  SettingsView.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import SwiftUI
import FirebaseAuth
import Firebase


struct SettingsView: View {
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @EnvironmentObject var checkoutVM : CheckoutViewModel

    @State var showCancelMembership = false
    @State var showProcessing = false
    @State var showError : Bool = false
    @State var showSuccess : Bool = false
    @State var errorTitle : String = "Something went wrong"
    @State var errorMessage : String = "There was an issue processing your payment. Please try again later"
    
    @State var name : String = ""
    
    var body: some View {
        
        ZStack {
            VStack {
                
                HStack {
                    Button(action: {
                        currentUser.showSettings = false
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))

                            .foregroundColor(Color("text-bold"))

                    })
                    
                    Text("Account Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("text-bold"))
                    
                    Spacer()
                }
                .padding()
                .padding(.bottom)

                HStack {
                    Text("Profile")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("text-bold"))
                    .padding(.leading, 5)
                    
                    Spacer()
                }
                .padding(.leading)
                
                ProfileTextField()


                HStack {
                    Text("Notifications")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("text-bold"))
                    .padding(.leading, 5)
                    
                    Spacer()
                }
                .padding(.leading)
                
                VStack(spacing : 0) {
                    
                    VStack {

                        AccountItemView(baseColor: .blue, icon: "iphone", title: "Push Notifications", isOn: $currentUser.user.isPushOn)
                            .onChange(of: currentUser.user.isPushOn) { oldValue, newValue in
                                if newValue {
                                    currentUser.enablePush()
                                } else {
                                    currentUser.disablePush()
                                }
                            }
                        

                    }
                    .padding(.horizontal)
                    .padding(.top)

                }
                .background(Color("background-element"))
                .cornerRadius(25)
                .shadow(color : Color("shadow-white"), radius : 1, x : -1, y : -1)
                .shadow(color : Color("shadow-black"), radius : 3, x : 2, y : 2)
                .padding(.horizontal)
                
                
                
                AccountSettingsSection()
                    .padding(.bottom)

                HStack {
                    Text("Membership")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("text-bold"))
                    .padding(.leading, 5)
                    
                    Spacer()
                }
                .padding(.leading)
                
                VStack(spacing : 0) {
                    
                    VStack {

                        if currentUser.isUserSubscribed {
                            Button  {
                                showCancelMembership = true
                            } label: {
                                HStack {
                                    ZStack {
                                        
                                        Circle()
                                            .frame(width : 35, height : 35)
                                            .foregroundStyle(
                                                .blue.gradient.shadow(.inner(color: .white.opacity(0.3), radius: 10, x: 3, y: 3))
                                            )
                                        Image(systemName: "crown")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .bold))

                                    }
                                    
                                    VStack(alignment : .leading) {
                                        Text("Premium Membership")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color("text-bold"))
                                            .padding(.leading, 5)
                                        
                                        Text("$9.99 / mo")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color("text-bold"))
                                            .padding(.leading, 5)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Active")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(.white))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 5)
                                        .background(Color("toggleOn"))
                                        .cornerRadius(10)

                                    
                                }
                                .padding(.bottom)
                            }
                        } else {
                            Button  {
                                
                                let manager = CheckoutControllerManager(checkout: checkoutVM, currentUser: currentUser, navigateToError: $showError, navigateToSuccess : $currentUser.showSuccessfulPayment)
                                manager.checkoutController.showApplePaySheet()
                                
                            } label: {
                                HStack {
                                    ZStack {
                                        
                                        Circle()
                                            .frame(width : 35, height : 35)
                                            .foregroundStyle(
                                                .blue.gradient.shadow(.inner(color: .white.opacity(0.3), radius: 10, x: 3, y: 3))
                                            )
                                        Image(systemName: "crown")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .bold))

                                    }
                                    
                                    VStack(alignment : .leading) {
                                        Text("Free Trial")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color("text-bold"))
                                            .padding(.leading, 5)
                                        
                                        let daysRemaining = currentUser.daysRemainingInFreeTrial(from: currentUser.user.dateCreated, trialLengthInDays: 7)
                                        Text("\(daysRemaining) days remaining")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color("text-bold"))
                                            .padding(.leading, 5)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Upgrade")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(.white))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 5)
                                        .background(Color("toggleOn"))
                                        .cornerRadius(10)

                                    
                                }
                                .padding(.bottom)
                            }
                            
                            
                        }
         

                    }
                    .padding(.horizontal)
                    .padding(.top)

                }
                .background(Color("background-element"))
                .cornerRadius(25)
                .shadow(color : Color("shadow-white"), radius : 1, x : -1, y : -1)
                .shadow(color : Color("shadow-black"), radius : 3, x : 2, y : 2)
                .padding(.horizontal)
                
                Spacer()
            }
            .onAppear { checkoutVM.preparePaymentSheet() }
            .background(Color("background"))
            .overlay(
                Color.black.opacity(showCancelMembership || showProcessing ? 0.5 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showCancelMembership = false
                        }
                    }
            )
            
            if showProcessing {
                ProgressView()
            }
            
            VStack {
                Spacer()
                ErrorMessageModal(showErrorMessageModal: $showError, title: errorTitle, message: errorMessage)
                    .centerGrowingModal(isPresented: showError)
                Spacer()
            }
            
            if showCancelMembership {
                CancelMembershipModal(showCancelMembership: $showCancelMembership)
                    .centerGrowingModal(isPresented: showCancelMembership)
            }
        }
    }
}



struct ProfileTextField : View {
    
    @EnvironmentObject var currentUser : CurrentUserViewModel
        
    @State var isEditing = false

    // Function to update user's name in Firestore
    func updateUserProfileName(name: String) {
        let db = Firestore.firestore()
        
        // Assuming 'users' is your collection and 'userID' is the ID for the current user
        // You'll need to replace 'userID' with the actual ID of the current user
        let userID = "userID" // You should dynamically fetch the actual user ID
        
        db.collection("users").document(userID).updateData([
            "name": name
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    var body: some View {
        
        
        VStack(alignment : .leading) {

            
            ZStack {
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("background-textfield")
                        .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                        .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                    )
                    .frame(height : 50)
                    .cornerRadius(15)

                
                HStack {
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(Color("placeholder"))
                        .padding(.trailing, 5 )
                        .padding(.leading)
                    
                    
                    if  currentUser.user.name == "" && !isEditing {
                    
                        Text(verbatim : "John Doe")
                            .font(.custom("SF Pro", size: 16))
                            .foregroundColor( Color("placeholder"))
                            .fontWeight(.bold)
                    }
                    
                    
                    Spacer()
                }
                
                TextField("", text: $currentUser.user.name, onEditingChanged: { isEditing in
                    self.isEditing = isEditing
                }, onCommit: {
                    // This is where you'd handle the submission for older versions of SwiftUI
                    updateUserProfileName(name: currentUser.user.name)
                })
                .frame(height: 40)
                .foregroundColor(.white)
                .padding(.leading, 50)
                .onSubmit {
                    // For SwiftUI 3.0 and later, handle the submission here
                    updateUserProfileName(name: currentUser.user.name)
                }

            }


        }
        .padding(.bottom, 30)
    }
}




struct CancelMembershipModal : View {
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @Environment(\.presentationMode) var presentationMode // Use the environment to access the presentation mode

    @Binding var showCancelMembership : Bool
    
    var body: some View {
        VStack(spacing : 0) {
            HStack {
                Button {
                    showCancelMembership = false
                    self.presentationMode.wrappedValue.dismiss()
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
                
                Text("Cancel Membership")
                    .font(.system(size: 18, weight : .bold))
                    .foregroundColor(Color("text-bold"))
                    .offset(x : -10)


                Spacer()

            }
            .padding()
            
            Text(verbatim: "Are you sure you'd like to cancel? You'll no longer be billed and will lose access to all premium features.")
                .font(.system(size: 14, weight : .medium))
                .foregroundColor(Color("text-bold"))
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            

            
            HStack(spacing : 15) {
                
                
                Button {
                    withAnimation {
                        currentUser.updateUser(data: ["isUserSubscribed" : false])
                        self.presentationMode.wrappedValue.dismiss()
                        showCancelMembership = false
                    }
                                        
                } label: {
                    HStack(spacing : 0) {
                        
                        Text("Unsubscribe")
                            .font(.system(size : 16, weight : .bold))
                            .foregroundColor(.white)
                    }
                    .frame( width : 200, height : 40)
                    .background(Color("toggleOn"))
                    .cornerRadius(10)
                    .shadow(color: Color("shadow-black"), radius: 3, x: 2, y: 2)
                }

            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
        

        }
        .frame(width : 350)
        .background(Color("background"))
        .cornerRadius(15)
        .outerShadow()
    }
}



struct AccountSettingsSection : View {
    
    @State var showLogoutAlert  = false
    
    func signOut () {
        do {
            try Auth.auth().signOut()
            print("Successfully signed out user")
            
        } catch {
            print("Error signing out user")
        }
    }
    
    var body: some View {
        HStack {
            Text("Account")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Color("text-bold"))
            .padding(.leading, 5)
            
            Spacer()
        }
        .padding(.leading)
        .padding(.top)
        
        VStack(spacing : 0) {
            
            
            VStack {
                
                Button(action: {
                    showLogoutAlert = true
                }, label: {
                    AccountItemNavigationView(baseColor: .orange, icon: "arrow.counterclockwise", title: "Sign Out")
                })
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("Are you sure you'd like to log out?"),
                        primaryButton: .destructive(Text("Log Out")) {
                            signOut()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                NavigationLink  {
                    ChangePasswordView()
                } label: {
                    AccountItemNavigationView(baseColor: .green, icon: "key.fill", title: "Change Password")
                }
                
                NavigationLink {
                    DeleteAccountView()
                } label: {
                    AccountItemNavigationView(baseColor: .red, icon: "trash.fill", title: "Delete Account")

                }
                
            }
            .padding(.horizontal)
            .padding(.top)

        }
        .background(Color("background-element"))
        .cornerRadius(25)
        .shadow(color : Color("shadow-white"), radius : 1, x : -1, y : -1)
        .shadow(color : Color("shadow-black"), radius : 3, x : 2, y : 2)
        .padding(.horizontal)
    }
}





struct AccountItemView : View {
    
    var baseColor : Color
    var icon : String
    var title : String
    
    @Binding var isOn : Bool
    
    var body: some View {
        HStack {
            ZStack {
                
                Circle()
                    .frame(width : 35, height : 35)
                    .foregroundStyle(
                        baseColor.gradient.shadow(.inner(color: .white.opacity(0.3), radius: 10, x: 3, y: 3))
                    )
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .bold))

            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("text-bold"))

                .padding(.leading, 5)
            
            Spacer()
            
            CustomToggleView(isOn: $isOn, title: "test")
            
        }
        .padding(.bottom)
    }
}




struct AccountItemNavigationView : View {
    
    var baseColor : Color
    var icon : String
    var title : String
        
    var body: some View {
        HStack {
            ZStack {
                
                Circle()
                    .frame(width : 35, height : 35)
                    .foregroundStyle(
                        baseColor.gradient.shadow(.inner(color: .white.opacity(0.3), radius: 10, x: 3, y: 3))
                    )
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .bold))

            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("text-bold"))
                .padding(.leading, 5)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("text-bold"))
                .padding(.trailing, 5)

        }
        .padding(.bottom)
    }
}


struct CustomToggleView: View {
    @Binding var isOn: Bool
    var title : String

    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(CustomToggleStyle())
    }
}


struct CustomToggleStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {
        
        
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("\(configuration.isOn ? "toggleOn" : "toggleOff")")
                    .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                    .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 0, y: 2))
                )
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .frame(height : 25)
                        .offset(x: configuration.isOn ? 10 : -10, y: 0)
                )
                .onTapGesture {
                    generateHapticFeedback()
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)

        }
    }
}





#Preview {
    SettingsView()
        .environmentObject( CurrentUserViewModel() )
}
