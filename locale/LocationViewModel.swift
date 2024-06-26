//
//  LocationViewManager.swift
//  locale
//
//  Created by Adrian Martushev on 3/2/24.
//

import Foundation
import Firebase
import FirebaseAuth
import CoreLocation
import MapKit


struct LocationAlert : Identifiable, Hashable {
    var id : String
    var lat : Double
    var lng : Double
    var userID : String
    var userName : String
    var profilePhoto : String
    var dateSent : Date
}

let empty_alert = LocationAlert(id: "anonymous", lat: 37.7749, lng: 122.4194, userID: "anonymous", userName : "", profilePhoto: "", dateSent: Date())


class LocationViewModel : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var locationAlerts: [LocationAlert] = [empty_alert]
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var locationString = ""
    @Published var locationToDisplay : LocationAlert = empty_alert

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
                listenForNearbyAlerts()
            @unknown default:
                break
        }
    }
    
    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async { [weak self] in
            self?.userLocation = location
        }
    }

    
    
    func listenForNearbyAlerts() {
        
        print("Fetching all global alerts from the last 24 hours within a 10-mile radius")

        let db = Firestore.firestore()
        let locationAlertsCollection = db.collection("locationAlerts")
        let usersCollection = db.collection("users")

        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let oneDayAgoTimestamp = Timestamp(date: oneDayAgo)

        locationAlertsCollection.whereField("dateSent", isGreaterThan: oneDayAgoTimestamp).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }

            var alerts: [LocationAlert] = []
            let dispatchGroup = DispatchGroup()

            for doc in documents {
                let data = doc.data()
                if let lat = data["latitude"] as? Double, let lng = data["longitude"] as? Double {
                    let alertLocation = CLLocation(latitude: lat, longitude: lng)
                    let distanceInMeters = self.userLocation!.distance(from: alertLocation)

                    print(self.userLocation!)
                    // Convert 10 miles to meters
                    let tenMilesInMeters = 16093.4

                    if distanceInMeters <= tenMilesInMeters {
                        let userID = data["userID"] as? String ?? ""
                        dispatchGroup.enter()

                        usersCollection.document(userID).getDocument { (userDocSnapshot, error) in
                            guard let userData = userDocSnapshot?.data(), error == nil else {
                                print("Error fetching user data: \(error!)")
                                dispatchGroup.leave()
                                return
                            }

                            let alert = LocationAlert(
                                id: doc.documentID,
                                lat: lat,
                                lng: lng,
                                userID: userID,
                                userName: userData["name"] as? String ?? "Unknown",
                                profilePhoto: userData["profilePhoto"] as? String ?? "",
                                dateSent: (data["dateSent"] as? Timestamp)?.dateValue() ?? Date()
                            )

                            alerts.append(alert)
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                print("Got location alerts within a 10-mile radius: \(alerts)")
                self.locationAlerts = alerts
            }
        }
    }

    
    func sendLocationAlert() {
        // Ensure there's a valid user location to work with
        guard let userLocation = self.userLocation else {
            print("User location is not available.")
            return
        }

        let db = Firestore.firestore() // Reference to Firestore
        let locationAlertsCollection = db.collection("locationAlerts")
        
        // Assume you have a way to obtain the current user's ID
        var userID = "anonymous"

        if let authID = Auth.auth().currentUser?.uid {
            userID = authID
        } else {
            print("No user is currently signed in.")
        }
        
        // Create a dictionary representing the data to save
        let alertData: [String: Any] = [
            "latitude": userLocation.coordinate.latitude,
            "longitude": userLocation.coordinate.longitude,
            "userID": userID,
            "dateSent": Timestamp(date: Date()),
            "locationString" : self.locationString
        ]

        // Add a new document to the "locationAlerts" collection
        locationAlertsCollection.addDocument(data: alertData) { error in
            if let error = error {
                // Handle any errors
                print("Error adding document: \(error.localizedDescription)")
            } else {
                // Document was added successfully
                print("Location alert sent successfully.")
                self.sendAlertToAllUsers()
            }
        }
    }
    
    
    /// Sends a notification request to the server.
    /// - Parameters:
    ///   - deviceToken: The device token as a string.
    ///   - alert: The message for the alert.
    ///   - badge: The badge number for the app icon.
    func sendNotification(deviceToken: String, alert: String, badge: Int) {
        // Ensure the URL matches your server's endpoint
        guard let url = URL(string: "https://locale-ios-d4e8c531cbbe.herokuapp.com/sendNotification/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the JSON body with the device token, alert, and badge
        let body: [String: Any] = [
            "token": deviceToken,
            "alert": alert,
            "badge": badge,
            "sound": "default"  // Assuming your server expects this; adjust as needed
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize JSON body: \(error.localizedDescription)")
            return
        }
        
        // Create and start a data task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the response or error
            if let error = error {
                print("Client error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Server returned an error")
                return
            }
            
            print("Notification sent successfully")
        }
        
        task.resume()
    }
    
    
    /// Fetches users with `isPushOn` set to true and sends a notification to each.
    func sendAlertToAllUsers() {
        let db = Firestore.firestore() // Reference to Firestore
        let usersCollection = db.collection("users") // Assuming your user data is stored in a collection named "users"
        
        // Query the users collection for users with isPushOn == true
        usersCollection.whereField("isPushOn", isEqualTo: true).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // Loop through the documents returned
                for document in querySnapshot!.documents {
                    guard let pushToken = document.data()["pushToken"] as? String else {
                        print("Push token not found for user: \(document.documentID)")
                        continue
                    }
                    
                    // Assuming you have a predefined alert message and badge number
                    let alertMessage = "New location alert"
                    let badgeNumber = 1 // Customize this as necessary
                    
                    // Send a notification to each user with isPushOn == true
                    self.sendNotification(deviceToken: pushToken, alert: alertMessage, badge: badgeNumber)
                }
            }
        }
    }
}
