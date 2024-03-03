//
//  SideMenuView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI

import SwiftUI

struct SideMenuView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    
    @Binding var showAccountMenu : Bool
    
    @State private var xOffset: CGFloat = -300 // Initial offset to start off-screen

    let menuItems : [String : String] = [
        "Profile" : "account-profile",
        "Settings" : "account-settings",
        "Privacy Policy" : "account-privacy",
        "Terms and Conditions" : "account-terms",
        "About Us" : "account-about",
        "Support" : "account-support",
        "Logout" : "account-logout"
    ]
    
    let menuItemOrder: [String] = [
        "Profile", "Settings", "Privacy Policy", "Terms and Conditions",
        "About Us", "Support", "Logout"
    ]
    
    @State var showProfile = false
    @State var showLogout = false
    
    
    var profilePhoto = "profile-2"
    
    var body: some View {
        
        HStack {
            VStack {
                
                VStack {
                    if ( currentUser.user.profilePhoto == "") {
                        
                        if currentUser.user.name != "" {
                            Text(getInitials(fullName: currentUser.user.name))
                                .font(.system(size: 24))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("16171D"))
                                .frame(width: 80, height: 80)
                                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                .cornerRadius(100)
                                .outerShadow()

                            
                        } else {
                            Image(systemName: "person.fill")
                                .font(Font.custom("Avenir Next", size: 40))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("placeholder"))
                                .frame(width: 80, height: 80)
                                .background(Color("background-element"))
                                .cornerRadius(100)
                                .outerShadow()
                        }
                        
                    } else {
                        CachedAsyncImageView(urlString: currentUser.user.profilePhoto)
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(.white, lineWidth: 1)
                            }
                            .outerShadow()

                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 20)

                
                Spacer().frame(height : 20)
                
                //Account Buttons
                VStack {
                    ForEach(menuItemOrder, id: \.self) { key in

                        Button(action: {
                            if key == "Logout" {
                                self.showLogout.toggle()
                            } else if key == "Profile" {
                                self.showProfile = true
                                showAccountMenu = false
                                
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
//                                            currentUser.signOut()
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

#Preview {
    SideMenuView( showAccountMenu: .constant(true))
}
