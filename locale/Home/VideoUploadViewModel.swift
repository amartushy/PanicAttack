//
//  VideoUploadViewModel.swift
//  locale
//
//  Created by Adrian Martushev on 3/9/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import AVFoundation // Import AVFoundation to work with video assets
import CoreLocation


class VideoUploadViewModel: ObservableObject {
    @Published var isShowingImagePicker = false
    @Published var isShowingConfirmation = false
    @Published var videoURL: URL?
    @Published var locationString = ""
    
    
    // This method now takes CLLocation as a parameter and is marked as async
    func uploadVideoToFirebase(with location: CLLocation) async {
        guard let videoURL = self.videoURL else { return }
        
        // First, update the location string
        await updateLocationString(with: location)
        
        // Calculate video duration
        let asset = AVURLAsset(url: videoURL)
        let durationInSeconds = CMTimeGetSeconds(asset.duration)

        let storageRef = Storage.storage().reference().child("videos/\(UUID().uuidString).mov")
        
        // Upload video file to Firebase Storage
        storageRef.putFile(from: videoURL, metadata: nil) { [weak self] metadata, error in
            guard let _ = metadata else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            // Fetch the download URL
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error?.localizedDescription ?? "Unknown error")
                    return
                }
                
                // Proceed to update Firestore with additional details
                DispatchQueue.main.async {
                    self?.updateFootageCollection(videoURL: downloadURL, durationInSeconds: durationInSeconds)
                }
            }
        }
    }
    
    private func updateLocationString(with location: CLLocation) async {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                // Construct a string from the placemark
                let locationString = [placemark.locality, placemark.administrativeArea, placemark.country].compactMap { $0 }.joined(separator: ", ")
                DispatchQueue.main.async {
                    self.locationString = locationString
                }
            }
        } catch {
            print("Error in reverse geocoding: \(error.localizedDescription)")
        }
    }
    
    func updateFootageCollection(videoURL: URL, durationInSeconds: Double) {
        let db = Firestore.firestore()
        let footageRef = db.collection("footage")
        
        let userId = Auth.auth().currentUser?.uid
        let locationAlertId = UUID().uuidString
        let dateTaken = Timestamp(date: Date())
        
        footageRef.addDocument(data: [
            "userId": userId ?? "",
            "dateTaken": dateTaken,
            "videoURL": videoURL.absoluteString,
            "locationAlertID": locationAlertId,
            "duration": durationInSeconds, // Store video duration in seconds
            "locationString": self.locationString // Store location string
        ]) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(locationAlertId)")
            }
        }
    }
}
