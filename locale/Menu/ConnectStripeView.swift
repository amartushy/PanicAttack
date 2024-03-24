//
//  ConnectStripeView.swift
//  locale
//
//  Created by Adrian Martushev on 3/23/24.
//

import Foundation
import SwiftUI


struct ConnectStripeView: View {
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @EnvironmentObject var onboardingVM : StripeOnboardingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var showStripeOnboarding : Bool

    @State var showLoading = false
    @State var showErrorMessageModal = false
    @State var errorTitle = "Something went wrong"
    @State var errorMessage = "There seems to be an issue. Please try again or contact support if the problem continues"
    
    var body: some View {
        
        ZStack {
            VStack {
                //Header
                ZStack {
                    HStack {
                        Button(action: {
                            showStripeOnboarding = false
                            generateHapticFeedback()

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
                        Text("Connect Account")
                            .font(Font.system(size: 18, weight: .bold))
                            .foregroundColor(Color("text-bold"))
                        Spacer()
                    }
                }
                .padding([.top, .bottom])
                .navigationTitle("")
                .navigationBarHidden(true)
                
                Divider()
                
                Spacer()
                
                VStack {
                    HStack(alignment : .center) {
                        
                        Image("panic_attack_logo_1024")
                            .resizable()
                            .scaledToFit()
                            .frame( height : 35)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.white)
                                    .frame( width : 110, height : 60)

                            }
                            .frame( width : 110, height : 60)


                        
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 18))
                            .foregroundColor(Color("text-bold"))
                            .padding(.horizontal, 5)
                        
                        Image("stripe-logo")
                            .resizable()
                            .scaledToFit()
                            .frame( height : 35)
                            .frame( width : 110, height : 60)
                            .background(.white)
                            .cornerRadius(5)


                    }
                    .padding(.bottom, 15)
                    
                    Text("PanicAttack partners with Stripe for secure payouts.")
                        .font(.system(size: 20, weight : .bold))
                        .foregroundColor(Color("text-bold"))
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment : .leading, spacing : 20) {
                        HStack(alignment: .top) {
                            Image(systemName: "building.columns")
                                .font(.system(size: 16, weight : .bold))

                            Text("Transfer earnings directly to your bank or debit card.")
                            
                        }
                        HStack(alignment: .top) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16, weight : .bold))

                            Text("We don't store any of your data.")
                            
                        }
                        HStack(alignment: .top) {
                            Image(systemName: "dollarsign.arrow.circlepath")
                                .font(.system(size: 16, weight : .bold))

                            Text("Get instant access to your available funds.")
                            
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
                    showLoading = true
                    
                    onboardingVM.createStripeExpressAccount(email: currentUser.user.email, userID: currentUser.currentUserID) { url, error in
                        if let url = url {
                            UIApplication.shared.open(url)
                            onboardingVM.stripeURL = nil //Reset to avoid repeated openings
                            showLoading = false
                        } else {
                            showErrorMessageModal = true
                            errorTitle = "Something went wrong"
                            errorMessage =  "\(error?.localizedDescription ?? "") \n\nThere was an error connecting with Stripe. Please contact support"
                            showLoading = false
                        }
                    }
                    
                } label: {
                    
                    HStack {
                        Spacer()

                        Text("Connect to Stripe")
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
                
                NavigationLink {
//                    ContactUsView(user: currentUser.user)
                } label: {
                    Text("Need help?")
                        .underline()
                        .font(.system(size: 14, weight : .medium))
                        .foregroundColor(Color("text-bold"))
                }


            }
            .background(Color("background"))
            .overlay(
                Color.black.opacity(showLoading || showErrorMessageModal ? 0.5 : 0)
                    .edgesIgnoringSafeArea(.all)
            )
            
            
            if showLoading {
                VStack {
                    Image("stripe-logo")
                        .resizable()
                        .scaledToFit()
                        .frame( height : 35)
                        .padding()
                    
                    ProgressView("Redirecting you to Stripe..")
                        .padding(.horizontal)
                        .padding(.bottom)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.black.opacity(0.7)))
                        .foregroundColor(Color.black.opacity(0.7))

                }
                .frame(width : 250, height : 250)
                .background(.white)
                .cornerRadius(10)

            }
            
            
            VStack {
                Spacer()
                ErrorMessageModal(showErrorMessageModal: $showErrorMessageModal, title: errorTitle, message: errorMessage)
                    .centerGrowingModal(isPresented: showErrorMessageModal)
                Spacer()
            }
            
        }
    }
}
