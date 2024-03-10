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

    
    @State var showSideMenu = false
    @State var showCreateLocation = false
    @State var showConfirmVideo = false

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
            
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .none,
                annotationItems: locationVM.locationAlerts) { alert in
                //                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: alert.lat, longitude: alert.lng), tint: .red)
                // Or use MapAnnotation for more customization
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: alert.lat, longitude: alert.lng)) {
                    // Custom annotation view
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

            HStack {
                
                VStack {
                    Button(action: {
                        withAnimation {
                            showSideMenu.toggle()
                        }
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.white)
                    })
                    .frame(width : 40, height : 40)
                    .background{
                        Color.black.opacity(0.9).cornerRadius(20.0)
                    }
                    .padding()
                    
                    Spacer()
                    
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                
                
                Spacer()
                
                VStack(alignment :.trailing, spacing : 0) {
                    VStack {
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
                            Image(systemName: "video")
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
                    
                    VStack {
                        Button(action: {
                            showCreateLocation = true

                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.white)
                                Text("PANIC")
                                    .font(.system(size: 18, weight : .bold))
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                    }
                    .background{
                        Color.red.cornerRadius(20.0)
                    }
                    .padding()
                    .frame(width : 160, height : 80)
                    

                }
            }
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
            
            SideMenuView(showAccountMenu: $showSideMenu)
                .leadingEdgeSheet(isPresented: showSideMenu)
            
            SettingsView()
                .trailingEdgeSheet(isPresented: currentUser.showSettings)

            TOSView()
                .bottomUpSheet(isPresented: currentUser.showTOS)
            
            VStack {
                Spacer()
                
                CreateNewLocationView(showSheet: $showCreateLocation)
                    .bottomUpSheet(isPresented: showCreateLocation)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)
            
            VStack {
                Spacer()
                
                ConfirmVideoUploadView(showSheet: $showConfirmVideo)
                    .bottomUpSheet(isPresented: showConfirmVideo)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)

        }
    }
}




struct MapView: UIViewRepresentable {
    
    @EnvironmentObject var locationViewModel: LocationViewModel

    @State var region = MKCoordinateRegion()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true // Show user location
        mapView.userTrackingMode = .follow // Automatically center the map on the user's location

        return mapView
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Assuming LocationViewModel has a way to provide a region; otherwise, this can be removed or adjusted.
//        uiView.setRegion(region, animated: true)
        
        // Remove all existing annotations (except for the user's location) and add fresh from locationAlerts
        let currentAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) }
        uiView.removeAnnotations(currentAnnotations)
        
        for alert in locationViewModel.locationAlerts {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: alert.lat, longitude: alert.lng)
            annotation.title = "Alert from \(alert.userID)" // Customize this as needed
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
    }
}



//#Preview {
//    HomeView()
//}
