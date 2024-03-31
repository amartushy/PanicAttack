//
//  UpgradePremiumView.swift
//  locale
//
//  Created by Adrian Martushev on 3/30/24.
//

import SwiftUI


struct UpgradePremiumView: View {
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @EnvironmentObject var checkoutVM : CheckoutViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var showProgress : Bool = false
    @State var showError : Bool = false
    @State var showSuccess : Bool = false
    @State var errorTitle : String = "Something went wrong"
    @State var errorMessage : String = "There was an issue processing your payment. Please try again later"
    
    var showExpiredText : Bool?
    
    var body: some View {
        
        ZStack {
            VStack {
                //Header
                ZStack {
                    HStack {
                        Button(action: {
                            generateHapticFeedback()
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
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
                        .padding(.leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Text("Premium Membership")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(Color("text-bold"))
                        Spacer()
                    }
                }
                .padding([.top, .bottom])
                .navigationTitle("")
                .navigationBarHidden(true)
                
                Divider()
                
                
                VStack {
                    Image("panic_attack_clear")
                        .resizable()
                        .scaledToFit()
                        .frame( height : 110)
                        .padding(.vertical, 30)
                    
                    if showExpiredText != nil {
                        Text("Your free trial has expired. Get unlimited access with a premium membership.")
                            .font(.system(size: 20, weight : .bold))
                            .foregroundColor(Color("text-bold"))
                            .multilineTextAlignment(.center)
                        
                    } else {
                        Text("Get unlimited access with a premium membership.")
                            .font(.system(size: 20, weight : .bold))
                            .foregroundColor(Color("text-bold"))
                            .multilineTextAlignment(.center)
                    }

                    
                    VStack(alignment : .leading, spacing : 20) {
                        HStack(alignment: .top) {
                            Image(systemName: "infinity")
                                .font(.system(size: 16, weight : .bold))

                            VStack(alignment : .leading) {
                                Text("Unlimited Alerts")
                                    .font(.system(size: 16, weight : .bold))
                                
                                Text("Send alerts whenever you're in trouble or need help")
                                    .font(.system(size: 14, weight : .regular))
                            }
                            
                        }
                        HStack(alignment: .top) {
                            Image(systemName: "dollarsign.arrow.circlepath")
                                .font(.system(size: 16, weight : .bold))

                            VStack(alignment : .leading) {
                                Text("Respond and Earn ")
                                    .font(.system(size: 16, weight : .bold))
                                
                                Text("Get paid to respond to alerts around you. The first 5 to record footage earn $$$")
                                    .font(.system(size: 14, weight : .regular))
                            }
                            
                        }

                    }
                    .padding(.top)
                    .font(.system(size: 14, weight : .regular))
                    .foregroundColor(Color("text-bold"))
                    .multilineTextAlignment(.leading)

                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                
                Divider()
                    .padding(.horizontal)
                
                                
                Button {
                    
                    let manager = CheckoutControllerManager(checkout: checkoutVM, currentUser: currentUser, navigateToError: $showError, navigateToSuccess : $currentUser.showSuccessfulPayment)
                    manager.checkoutController.showApplePaySheet()
                    
                } label: {
                    
                    HStack {
                        Spacer()

                        Text("Subscribe $9.99 / mo")
                            .font(.system(size: 16, weight : .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()

                    }
                    .padding()
                    .frame(height : 50)
                    .background(Color("stripe-purple"))
                    .cornerRadius(10)
                    .outerShadow()

                }
                .padding(.vertical, 30)
                .padding(.horizontal, 30)
                .onAppear { checkoutVM.preparePaymentSheet() }

                
            }
            .background(Color("background"))
            .overlay(
                Color.black.opacity(showProgress || showError ? 0.5 : 0)
                    .edgesIgnoringSafeArea(.all)
            )
            
            if showProgress {
                ProgressView("Processing..")
            }
            
            
            VStack {
                Spacer()
                ErrorMessageModal(showErrorMessageModal: $showError, title: errorTitle, message: errorMessage)
                    .centerGrowingModal(isPresented: showError)
                Spacer()
            }
            
        }
    }
}


struct BookingSuccessModal : View {
    @EnvironmentObject var currentUser : CurrentUserViewModel

    @Binding var showModal : Bool
    
    var title : String
    var message : String
    @Environment(\.presentationMode) var presentationMode // Use the environment to access the presentation mode

    var body: some View {
        VStack(spacing : 0) {
            HStack {
                Button {
                    showModal = false
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
                
                Text(title)
                    .font(.system(size: 18, weight : .bold))
                    .foregroundColor(Color("text-bold"))
                    .offset(x : -10)


                Spacer()

            }
            .padding()
            
            Text(verbatim: message)
                .font(.system(size: 14, weight : .medium))
                .foregroundColor(Color("text-bold"))
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            

            
            HStack(spacing : 15) {
                
                
                Button {
                    withAnimation {
                        self.presentationMode.wrappedValue.dismiss()
                        showModal = false
                    }
                                        
                } label: {
                    HStack(spacing : 0) {
                        
                        Text("Ok")
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



//#Preview {
//    UpgradePremiumView()
//        .environmentObject(CurrentUserViewModel())
//        .environmentObject(StoreManager())
//
//}
