//
//  SettingsView.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import SwiftUI
import FirebaseAuth



struct SettingsView: View {
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    @State var isPushOn = false
    
    var body: some View {
        
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
            
            Spacer()
        }
        .background(Color("background"))
        
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
}
