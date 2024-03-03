//
//  TOSView.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import SwiftUI


import SwiftUI

struct TOSView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var showTOS : Binding<Bool>?
    
    var body: some View {
        

        VStack {
            VStack(alignment : .leading) {
                HStack(spacing: 0) {
                    Button(action: {
                        if let showTOS = showTOS {
                            showTOS.wrappedValue = false
                        } else {
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }
                        
                    }) {
                        Image(systemName: (showTOS != nil) ? "xmark" : "arrow.left")
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
                    
                    Text("Terms of Service & Privacy Policy")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("text-bold"))
                    .padding(.horizontal)
                    
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                
                
                ScrollView{
                    Text("\(TOSString)")
                        .font(Font.system(size:10))
                }
            }
            .padding()
        }
        .background {
            Color("background")
                .edgesIgnoringSafeArea(.all)

        }
    }
    
    var TOSString = """
            Terms of Service and Privacy Policy
    
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    """
}

#Preview {
    TOSView()
}
