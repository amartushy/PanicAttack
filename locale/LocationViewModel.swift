//
//  LocationViewManager.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import Foundation
import Firebase
import CoreLocation


struct LocationAlert : Identifiable, Hashable {
    var id : String
    var lat : Double
    var lng : Double
    var userID : String
    var dateSent : Date
}

class LocationViewModel : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var locationAlerts: [LocationAlert] = []
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // Respond to authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined:
                // Request when-in-use authorization initially
                manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                // Handle case where user has denied or restricted location services
                break
            case .authorizedWhenInUse, .authorizedAlways:
                // Permission granted, start location updates
                manager.startUpdatingLocation()
            @unknown default:
                break
        }
    }
    
    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async { [weak self] in
            self?.userLocation = location // Update published userLocation
        }
    }
    
    func listenForNearbyAlerts() {
            guard let userLocation = self.userLocation else {
                print("User location is not available.")
                return
            }
            
            let db = Firestore.firestore()
            let locationAlertsCollection = db.collection("locationAlerts")
            
            // Constants for calculating the radius
            let earthRadiusMiles = 3958.8
            let radiusMiles = 10.0
            let maxLatitude = userLocation.coordinate.latitude + (radiusMiles / earthRadiusMiles) * (180 / .pi)
            let minLatitude = userLocation.coordinate.latitude - (radiusMiles / earthRadiusMiles) * (180 / .pi)
            
            // Assuming longitude calculations are simplified and ignoring edge cases
            let maxLongitude = userLocation.coordinate.longitude + (radiusMiles / earthRadiusMiles) * (180 / .pi) / cos(userLocation.coordinate.latitude * .pi / 180)
            let minLongitude = userLocation.coordinate.longitude - (radiusMiles / earthRadiusMiles) * (180 / .pi) / cos(userLocation.coordinate.latitude * .pi / 180)
            
            // Firestore query for documents within the latitude and longitude bounds
            locationAlertsCollection.whereField("latitude", isGreaterThan: minLatitude)
                                    .whereField("latitude", isLessThan: maxLatitude)
                                    .whereField("longitude", isGreaterThan: minLongitude)
                                    .whereField("longitude", isLessThan: maxLongitude)
                                    .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                let alerts = documents.map { doc -> LocationAlert in
                    let data = doc.data()
                    return LocationAlert(
                        id: doc.documentID,
                        lat: data["latitude"] as? Double ?? 0,
                        lng: data["longitude"] as? Double ?? 0,
                        userID: data["userID"] as? String ?? "",
                        dateSent: (data["dateSent"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                
                DispatchQueue.main.async {
                    self.locationAlerts = alerts
                }
            }
        }
    
    private func sendLocationAlert() {
        // Ensure there's a valid user location to work with
        guard let userLocation = self.userLocation else {
            print("User location is not available.")
            return
        }

        let db = Firestore.firestore() // Reference to Firestore
        let locationAlertsCollection = db.collection("locationAlerts")
        
        // Assume you have a way to obtain the current user's ID
        let userID = "someUserID" // This should be replaced with the actual user ID retrieval logic

        // Create a dictionary representing the data to save
        let alertData: [String: Any] = [
            "latitude": userLocation.coordinate.latitude,
            "longitude": userLocation.coordinate.longitude,
            "userID": userID,
            "dateSent": Timestamp(date: Date()) // Firestore Timestamp object
        ]

        // Add a new document to the "locationAlerts" collection
        locationAlertsCollection.addDocument(data: alertData) { error in
            if let error = error {
                // Handle any errors
                print("Error adding document: \(error.localizedDescription)")
            } else {
                // Document was added successfully
                print("Location alert sent successfully.")
            }
        }
    }
}
