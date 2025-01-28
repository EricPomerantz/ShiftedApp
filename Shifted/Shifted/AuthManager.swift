//
//  AuthManager.swift
//  Shifted
//
//  Created by Leslie Jungbluth on 12/8/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var user: User? // Tracks the Firebase user
    @Published var isSignedIn: Bool = false // Tracks the sign-in status

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for authentication state changes
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isSignedIn = user != nil
        }
    }

    deinit {
        // Remove the listener when the manager is deinitialized
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String, firstName: String, lastName: String) {
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                self.user = authResult.user

                // Update the user's profile with their name
                let changeRequest = self.user?.createProfileChangeRequest()
                changeRequest?.displayName = "\(firstName) \(lastName)"
                try await changeRequest?.commitChanges()

                // Save the user's details to Firestore
                saveUserDataToFirestore(uid: authResult.user.uid, firstName: firstName, lastName: lastName)
            } catch {
                print("Sign-up error: \(error.localizedDescription)")
            }
        }
    }

    func signIn(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                user = authResult.user // Update the user property
            } catch {
                print("Login error: \(error.localizedDescription)")
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil // Clear the user on sign-out
        } catch {
            print("Sign-out error: \(error.localizedDescription)")
        }
    }

    private func saveUserDataToFirestore(uid: String, firstName: String, lastName: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.setData([
            "firstName": firstName,
            "lastName": lastName
        ]) { error in
            if let error = error {
                print("Error saving user data to Firestore: \(error.localizedDescription)")
            } else {
                print("User data saved to Firestore.")
            }
        }
    }
}

