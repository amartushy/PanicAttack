//
//  SplashScreen.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        HStack {
            Spacer()

            VStack {
                Spacer()
                
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 100))
                    .outerShadow()
                
                
                VStack {

                    Text("App Name")
                        .font(.system(size: 32, weight : .bold))
                }
                .padding(.top)

                
                Spacer()
            }
            
            Spacer()

        }
        .background {
            Color("background")
        }
        .edgesIgnoringSafeArea(.all)

    }
}

#Preview {
    SplashScreen()
}
