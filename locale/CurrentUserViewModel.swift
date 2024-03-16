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
    var balance : Double
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
                                      balance : 0.0,
                                      dateCreated : Date(),
                                      email: "",
                                      isPushOn: false,
                                      name : "",
                                      profilePhoto: "",
                                      pushToken : "",
                                      lat : 0.0,
                                      lng : 0.0 )
    
    
    //Navigation
    @Published var showSettings : Bool = false
    @Published var showTOS : Bool = false
    @Published var showPrivacyPolicy : Bool = false
    @Published var showAboutUs : Bool = false
    
    //Refresh ID to force view updates (Photo selection..)
    @Published var refreshID = UUID()

    
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
            
            self.user.balance = document.get("balance") as? Double ?? 0.0
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
                                   balance : 0.0,
                                   dateCreated: Date(),
                                   email: email,
                                   isPushOn: false,
                                   name: "",
                                   profilePhoto: "",
                                   pushToken: self.delegate.deviceToken,
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
    
    
    
    
    // Function to upload image to Firebase Storage
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let imageData = image.jpegData(compressionQuality: 0.4)
        let storageRef = Storage.storage().reference().child("profileImages/\(self.currentUserID).jpg")

        storageRef.putData(imageData!, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }
    }
    
    // Function to update user's profile photo URL in Firestore
    func updateUserProfilePhotoURL(_ url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()

        db.collection("users").document(self.currentUserID).updateData(["profilePhoto": url.absoluteString]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("Successfully updated profile photo")
                completion(.success(()))
            }
        }
    }
    
    
    
    func enablePush() {
                
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                print("Failed to register with error: \(error.localizedDescription)")
            } else {
                print("Success! We authorized notifications")
                //Get device token to update firestore
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    let userRef = database.collection("users").document(self.currentUserID)
                    userRef.updateData(["isPushOn": true, "pushToken": self.user.pushToken]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Push Notifications Enabled with token \(self.user.pushToken)")
                        }
                    }
                }
            }
        }
    }
    
    func disablePush() {
        let userRef = database.collection("users").document(self.currentUserID)
        self.user.pushToken = ""
        userRef.updateData([ "isPushOn": false, "pushToken" : self.user.pushToken]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Disabled push notifications")
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
    
    func reauthenticateAndUpdatePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, "User not logged in")
            return
        }
        
        // Reauthenticate the user
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                // Handle reauthentication failure
                completion(false, error.localizedDescription)
                return
            }
            
            // User reauthenticated successfully, now update the password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    // Handle password update failure
                    completion(false, error.localizedDescription)
                } else {
                    // Password updated successfully
                    print("Password updated successfully")
                    completion(true, nil)
                }
            }
        }
    }
    
    func deleteUserAccount(currentPassword: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(false, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        // Reauthenticate the user
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(false, error)
                return
            }
            user.delete { error in
                if let error = error {
                    completion(false, error)
                } else {
                    // Successfully deleted user account
                    completion(true, nil)
                }
            }
        }
    }    
    

    func submitWithdrawal(withdrawalData: [String: Any], completion: @escaping (Bool, String) -> Void) {
            guard let withdrawalAmountDouble = withdrawalData["amount"] as? Double else {
                print("Amount not found or invalid in withdrawalData")
                completion(false, "Amount not found or invalid.")
                return
            }
            
            let db = Firestore.firestore()
            let withdrawalRef = db.collection("withdrawals").document()
            let userRef = db.collection("users").document(currentUserID)
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let userDocument: DocumentSnapshot
                do {
                    try userDocument = transaction.getDocument(userRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                let oldBalance = userDocument.data()?["balance"] as? Double  ?? 0.0
                
                if oldBalance < withdrawalAmountDouble {
                    let error = NSError(domain: "App", code: 0, userInfo: [NSLocalizedDescriptionKey: "Insufficient funds"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                let newBalance = oldBalance - withdrawalAmountDouble
                
                transaction.updateData(["balance": newBalance], forDocument: userRef)
                transaction.setData(withdrawalData, forDocument: withdrawalRef)
                
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                    completion(false, "Transaction failed: \(error.localizedDescription)")
                } else {
                    print("Transaction successfully committed!")
                    completion(true, "Transaction successfully committed!")
                }
            }
        }


}
