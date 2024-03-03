//
//  CurrentUserViewModel.swift
//  locale
//
//  Created by Adrian Martushev on 2/24/24.
//


import SwiftUI
import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


struct User: Identifiable, Hashable, Codable {
    var id: String
    var dateCreated : Date
    var email : String
    var isPushOn : Bool
    var name: String
    var profilePhoto: String
    var pushToken : String
    var lat : Double
    var lng : Double
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "dateCreated": dateCreated,
            "email": email,
            "isPushOn": isPushOn,
            "name": name,
            "profilePhoto" : profilePhoto,
            "pushToken": pushToken,
            "lat" : lat,
            "lng" : lng
        ]
    }
}

let database = Firestore.firestore()


class CurrentUserViewModel: ObservableObject {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @Published var isAppLoading = true
    @Published var latitude : Double = 0.0
    @Published var longitude : Double = 0.0

    @Published var user : User = User(id: "",
                                      dateCreated : Date(),
                                      email: "",
                                      isPushOn: false,
                                      name : "",
                                      profilePhoto: "",
                                      pushToken : "",
                                      lat : 0.0,
                                      lng : 0.0 )
    
    
    
    //Handles real-time authentication changes to conditionally display login/home views
    var didChange = PassthroughSubject<CurrentUserViewModel, Never>()
    
    @Published var currentUserID: String = "" {
        didSet {
            didChange.send(self)
        }
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    func listen () {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                
                print("User Authenticated: \(user.uid)")
                self.currentUserID = user.uid
                self.getUserInfo(userID: user.uid)
                
            } else {
                print("No user available, loading initial view")
                self.currentUserID = ""
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.isAppLoading = false
                    }
                }
            }
        }
    }
    
    
    //Fetch initial data once, add listeners for appropriate conditions
    func getUserInfo(userID: String) {
        let userInfo = database.collection("users").document(userID)
        
        userInfo.getDocument { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard document.exists else {
                //This case should never exist unless there's a major issue - sign the user out to restart flow
                print("User document does not exist in database, terminating authentication")
                self.signOut()
                
                return
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.isAppLoading = false
                }
            }
            self.listenForCoreUserChanges(userID: self.currentUserID)
        }
    }
    
    func listenForCoreUserChanges(userID: String) {
        database.collection("users").document(userID).addSnapshotListener { [self] snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            var dateCreated = Date()
            if let dateCreatedTimestamp = document.get("dateCreated") as? Timestamp {
                dateCreated = dateCreatedTimestamp.dateValue()
            }
            
            self.user.dateCreated = dateCreated
            self.user.email = document.get("email") as? String ?? ""
            self.user.isPushOn = document.get("isPushOn") as? Bool ?? false
            self.user.name = document.get("name") as? String ?? ""
            self.user.profilePhoto = document.get("profilePhoto") as? String ?? ""
            self.user.pushToken = document.get("pushToken") as? String ?? ""
            self.user.lat = document.get("lat") as? Double ?? 0.0
            self.user.lng = document.get("lng") as? Double ?? 0.0

            //Initialize core properties
            self.user.id = document.documentID

        }
    }
    
    
    func createUser(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        
        //Create auth user
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating auth user: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else if let authResult = authResult {
                                
                // Create a new user
                let newUser = User(id: authResult.user.uid,
                                   dateCreated: Date(),
                                   email: email,
                                   isPushOn: false,
                                   name: "",
                                   profilePhoto: "",
                                   pushToken: "",
                                   lat: 0.0,
                                   lng: 0.0)

                // Convert user to dictionary
                let data = newUser.toDictionary()
                print("Creating new user with data : \(data)")
                
                // Add user to Firestore
                database.collection("users").document(authResult.user.uid).setData(data) { error in
                    if let error = error {
                        // Handle any errors here
                        print("Error writing user to Firestore: \(error.localizedDescription)")
                        completion(false, error.localizedDescription)
                    } else {
                        // Success
                        print("User successfully written to Firestore")
                        completion(true, "")
                    }
                }
            }
        }
    }
    
    
    func updateUserWithCompletion(data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let userInfo = database.collection("users").document(self.currentUserID)
        userInfo.updateData(data) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(.failure(err))
            } else {
                print("User data successfully updated : \(data)")
                completion(.success(()))
            }
        }
    }
    
    func updateUser(data: [String: Any]) {
        let userInfo = database.collection("users").document(self.currentUserID)
        userInfo.updateData(data) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("User data successfully updated: \(data)")
            }
        }
    }
    
    
    func signOut () {
        do {
            try Auth.auth().signOut()
            print("Successfully signed out user")
            
        } catch {
            print("Error signing out user")
        }
    }
}