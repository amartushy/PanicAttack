//
//  ContentView.swift
//  locale
//
//  Created by Adrian Martushev on 2/18/24.
//

import SwiftUI
import MapKit
import CoreLocation


struct HomeView: View {
    @EnvironmentObject var locationVM : LocationViewModel
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @EnvironmentObject var viewModel : VideoUploadViewModel
    @EnvironmentObject var onboardingVM : StripeOnboardingViewModel

    
    @State var showSideMenu = false
    @State var showCreateLocation = false
    @State var showConfirmVideo = false
    @State var showInfoOverlay = false

    @State var showWithdrawal = false
    @State var showStripeOnboarding = false
    @State var showUpgrade = false
    
    
    
    //Initialize to San Francisco
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), latitudinalMeters: 1000, longitudinalMeters: 1000)
    
    private func updateRegion(with location: CLLocation?) {
        guard let location = location else { return }
        let coordinate = location.coordinate
        
        region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
    
    @State var shouldRecenterMap = true

    
    var body: some View {
        ZStack {
            
            VStack {
                ZStack {
                    Map(coordinateRegion: $region,
                        showsUserLocation: true,
                        userTrackingMode: .none,
                        annotationItems: locationVM.locationAlerts) { alert in
                        //                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: alert.lat, longitude: alert.lng), tint: .red)
                        // Or use MapAnnotation for more customization
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: alert.lat, longitude: alert.lng)) {
                            // Custom annotation view
//                            CustomMarkerView()
                            ProfilePhotoOrInitial(profilePhoto: "", fullName: alert.userID, radius: 40, fontSize: 20)
                        }
                    }
                    .onChange(of: locationVM.userLocation) { _, newLocation in
                        if shouldRecenterMap {
                            updateRegion(with: newLocation)
                            shouldRecenterMap = false
                        }
                    }
                    .ignoresSafeArea()
                    
                    MapOverlayButtons(showSideMenu : $showSideMenu,
                                      showCreateLocation: $showCreateLocation,
                                      showConfirmVideo: $showConfirmVideo,
                                      showInfoOverlay: $showInfoOverlay,
                                      region : $region
                    )
                }
                
                ZStack {
                    VStack(alignment : .center) {
                        Spacer()
                        Text("When you are in trouble, tap the panic button")
                            .font(.system(size: 18, weight : .bold))
                            .foregroundColor(Color("text-bold"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        Button(action: {

                            if currentUser.isUserSubscribed {
                                showCreateLocation = true
                            } else {
                                showUpgrade = true
                            }
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.white)
                                Text("PANIC")
                                    .font(.system(size: 18, weight : .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                        }
                        .background{
                            Color(.red).cornerRadius(20.0)
                                .outerShadow()

                        }
                        .padding()
                        .frame( height : 80)
                        .cornerRadius(20.0)
                        .sheet(isPresented: $showUpgrade) {
                            UpgradePremiumView(showExpiredText: true)
                        }


                        
                        Text("Members within 10 miles will be alerted")
                            .font(.system(size: 14, weight : .semibold))
                            .foregroundColor(Color("text-bold"))
                            .padding(.horizontal, 30)
                            .padding(.bottom, 40)

                    }
                    .frame(height : 220)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("background-textfield")
                                .shadow(.inner(color: .white.opacity(0.8), radius: 1, x: 0, y: -1))
                                .shadow(.inner(color: .black.opacity(0.3), radius: 2, x: 2, y: 2))
                            )
                    }
                    .offset(y : -8)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                        }
                        .frame(height : 20)
                        .background(Color("background-textfield"))
                    }
                    .frame(height : 220)

                }

                
            }
            .background(Color("background"))
            .overlay(
                Color.black.opacity(showSideMenu || showCreateLocation ? 0.5 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showSideMenu = false
                            showCreateLocation = false
                        }
                    }
            )
            
            SideMenuView(showAccountMenu: $showSideMenu, showWithdrawal: $showWithdrawal, showStripeOnboarding: $showStripeOnboarding)
                .leadingEdgeSheet(isPresented: showSideMenu)
            
            VStack {
                Spacer()
                BookingSuccessModal(showModal: $currentUser.showSuccessfulPayment, title: "Success!", message: "Your payment was successful")
                    .centerGrowingModal(isPresented: currentUser.showSuccessfulPayment)
                Spacer()
            }
            
            SettingsView()
                .trailingEdgeSheet(isPresented: currentUser.showSettings)

            TOSView()
                .bottomUpSheet(isPresented: currentUser.showTOS)
            
            ConnectStripeView(showStripeOnboarding : $showStripeOnboarding)
                .trailingEdgeSheet(isPresented: showStripeOnboarding)

            
            WithdrawView(showWithdrawal : $showWithdrawal)
                .trailingEdgeSheet(isPresented: showWithdrawal)
            
            VStack {
                Spacer()
                ErrorMessageModal(showErrorMessageModal: $currentUser.showSuccessfulUpload, title: "Successfully Uploaded!", message: "Your upload was successful and your balance has been updated. Thanks!")
                    .centerGrowingModal(isPresented: currentUser.showSuccessfulUpload)
                Spacer()
            }
            
            VStack {
                Spacer()
                
                CreateNewLocationView(showSheet: $showCreateLocation)
                    .bottomUpSheet(isPresented: showCreateLocation)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)
            
            VStack {
                Spacer()
                
                ConfirmVideoUploadView(showSheet: $showConfirmVideo, showUploadAvailable: true)
                    .bottomUpSheet(isPresented: showConfirmVideo)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)

        }
        .edgesIgnoringSafeArea(.bottom)

    }
}




struct MapOverlayButtons : View {
    @EnvironmentObject var locationVM : LocationViewModel
    @EnvironmentObject var currentUser : CurrentUserViewModel
    @EnvironmentObject var viewModel : VideoUploadViewModel
    
    @Binding var showSideMenu : Bool
    @Binding var showCreateLocation : Bool
    @Binding var showConfirmVideo : Bool
    @Binding var showInfoOverlay : Bool
    
    @Binding var region : MKCoordinateRegion
    
    private func updateRegion(with location: CLLocation?) {
        guard let location = location else { return }
        let coordinate = location.coordinate
        
        region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
    
    var body: some View {
        HStack {
            
            VStack {
                Button(action: {
                    withAnimation {
                        showSideMenu.toggle()
                    }
                }, label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                        .padding()
                        .padding(.vertical, 5)
                })
                .background{
                    Color.black.opacity(0.9).cornerRadius(20.0)
                }
                .padding()
                
                Spacer()
                
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            
            
            Spacer()
            
            VStack {
                HStack {
                    Text("You are within 10 miles of the alerts on this map")
                        .font(.system(size: 12, weight : .bold))
                        .foregroundColor(Color("text-bold"))
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .background{
                    Color.black.opacity(0.9).cornerRadius(20.0)
                }
                
                Spacer()
            }
            .padding()


            
            Spacer()
            
            VStack(alignment :.trailing, spacing : 0) {
                VStack {
                    
                    Button(action: {
                        showInfoOverlay = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Divider()
                    
                    Button(action: {
                        updateRegion(with: locationVM.userLocation)
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Divider()
                    
                    Button(action: {
                        viewModel.isShowingImagePicker = true

                    }, label: {
                        Image(systemName: "video.fill")
                            .foregroundColor(.white)
                            .padding()
                    })
                }
                .background{
                    Color.black.opacity(0.9).cornerRadius(20.0)
                }
                .padding()
                .frame(width : 80)
                .sheet(isPresented: $viewModel.isShowingImagePicker, onDismiss: {
                    // This checks if a video was selected and triggers the confirmation view
                    if viewModel.videoURL != nil {
                        self.showConfirmVideo = true
                    }
                }) {
                    VideoCaptureView(videoURL: $viewModel.videoURL)
                }


                Spacer()
            

            }
        }
    }
}

//struct MapView: UIViewRepresentable {
//    
//    @EnvironmentObject var locationViewModel: LocationViewModel
//
//    @State var region = MKCoordinateRegion()
//    
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.showsUserLocation = true // Show user location
//        mapView.userTrackingMode = .follow // Automatically center the map on the user's location
//
//        return mapView
//    }
//    
//    
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // Assuming LocationViewModel has a way to provide a region; otherwise, this can be removed or adjusted.
////        uiView.setRegion(region, animated: true)
//        
//        // Remove all existing annotations (except for the user's location) and add fresh from locationAlerts
//        let currentAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) }
//        uiView.removeAnnotations(currentAnnotations)
//        
//        for alert in locationViewModel.locationAlerts {
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: alert.lat, longitude: alert.lng)
//            annotation.title = "Alert from \(alert.userID)" // Customize this as needed
//            uiView.addAnnotation(annotation)
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: MapView
//        
//        init(_ parent: MapView) {
//            self.parent = parent
//        }
//        
//    }
//}


struct CustomMarkerView: View {
    var body: some View {
        ZStack {
            // Outer circle with exclamation mark
            Circle()
                .foregroundColor(.red)
                .frame(width: 30, height: 30)
            
            Image(systemName: "triangle.exclamation")
                .foregroundColor(.white)
                .font(.system(size: 16))
            
            // Inverted triangle below the circle
            Path { path in
                let start = CGPoint(x: 15, y: 30)
                path.move(to: start)
                path.addLine(to: CGPoint(x: 0, y: 45))
                path.addLine(to: CGPoint(x: 30, y: 45))
                path.addLine(to: start)
            }
            .foregroundColor(.red)
        }
    }
}



//#Preview {
//    HomeView()
//}
