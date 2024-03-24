//
//  InitialView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI
import MapKit


struct InitialView: View {
    @EnvironmentObject var currentUser : CurrentUserViewModel
    
    @State var showTOS = false
    
    @State private var circleRadius: Double = 1 // Default radius in miles
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 1000, longitudinalMeters: 1000)
    
    @EnvironmentObject var locationVM : LocationViewModel
    
    private func updateRegion(with location: CLLocation?) {
        guard let location = location else { return }
        let coordinate = location.coordinate
        
        // Update currentUserViewModel with the new location
        
        region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
    }
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                ZStack {
                    
                    Color("background")
                        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    
                    VStack {
                        
                        Spacer()

                        HStack {
                            Spacer()
                            Image("panic_attack_clear")
                                .resizable()
                                .scaledToFit()
                                .frame(height : 100)

                            Spacer()
                        }
                        
                        Spacer()
                        
                        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .none)
                            .cornerRadius(10)
                            .onChange(of: locationVM.userLocation) { newLocation in
                                updateRegion(with: newLocation)
                            }
                            .padding(.horizontal)
                            .frame(width : 350, height : 350)


                        
                        Spacer()
                        
                        //Buttons
                        VStack(spacing:20) {
                            
                            //Login  Button
                            NavigationLink {
                                LoginView()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Login")
                                        .font(.custom("Avenir Next", size: 16))
                                        .font(Font.system(size: 18))
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding()
                                .background(Color("background-element"))
                                .cornerRadius(15)
                                .outerShadow()

                            }

                            
                            //Create account
                            NavigationLink {
                                CreateAccountView()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Create Account")
                                        .font(.custom("Avenir Next", size: 16))
                                        .font(Font.system(size: 18))
                                        .foregroundColor(Color(.white))
                                        .fontWeight(.semibold)

                                    Spacer()
                                }
                                .frame(height: 50)
                                .background(Color(.blue))
                                .cornerRadius(15)
                                .outerShadow()
                            }
//                            
//                            
//                            NavigationLink {
//                                HomeView()
//                            } label: {
//                                HStack {
//                                    Spacer()
//                                    Text("Skip")
//                                        .font(.custom("Avenir Next", size: 16))
//                                        .foregroundColor(Color(.white).opacity(0.6))
//                                        .underline()
//                                    Spacer()
//                                }
//                                .frame(height: 30)
//                                .cornerRadius(15)
//                                .outerShadow()
//                            }
                            
                            VStack {
                                Text("By continuing you agree to the")
                                HStack(spacing : 0) {
                                    Button {
                                        showTOS = true
                                    } label: {
                                        Text("Terms & Conditions").underline()
                                    }
                                    
                                    Text("and   ")
                                    
                                    Button {
                                        showTOS = true
                                    } label: {
                                        Text("Privacy Policy").underline()
                                    }
                                }
                            }
                            .font(Font.custom("Avenir Next", size: 10))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.white))
                            .frame(width: 193, height: 40, alignment: .center)

                        }
                        .padding(.leading)
                        .padding(.trailing)
                        .frame(width : 350)
                    }
                    
                    
//                    TOSView(showTOS : $showTOS)
//                        .bottomUpSheet(isPresented: showTOS)
                    
                    
                } //end ZStack
            }
        }
    }
}

#Preview {
    InitialView()
}
