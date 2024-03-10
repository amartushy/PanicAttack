//
//  MotherView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI

struct MotherView: View {
    
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    
    var body: some View {
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

    }
}

#Preview {
    MotherView()
}
