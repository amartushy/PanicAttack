//
//  MotherView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI

struct MotherView: View {
    
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    @State var isSplashShowing = true
    
    var body: some View {
        
        ZStack {
            NavigationStack {
                if currentUser.currentUserID != "" {
                    HomeView()
                    
                } else {
                    InitialView()

                }
            }
            .onAppear {
                currentUser.listen()
            }
            
            if isSplashShowing {
                SplashScreen()
                    .transition(.opacity)
            }
            
            
        }
        .onAppear {
            currentUser.listen()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Wait for 2 seconds
                withAnimation {
                    isSplashShowing = false // This will trigger the fade out
                }
            }
        }


    }
}

#Preview {
    MotherView()
        .environmentObject(CurrentUserViewModel())
}
