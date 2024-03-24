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
                
                Image("panic_attack_clear")
                    .resizable()
                    .scaledToFit()
                    .frame(height : 200)
                    .outerShadow()
                
                ProgressView()
                    .padding(.top)
                
                Spacer()

                Text("Panic Attack LLC \nv1.0.0")
                    .font(.system(size: 12, weight : .bold))
                    .foregroundColor(Color("text-bold"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                            
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
