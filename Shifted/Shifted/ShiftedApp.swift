//
//  ShiftedApp.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/7/24.
//

import SwiftUI
import FirebaseCore

@main
struct ShiftedApp: App {
    @StateObject private var authManager = AuthManager() // Shared instance of AuthManager

    init() {
        FirebaseApp.configure() // Initialize Firebase
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isSignedIn {
                TabBarView()
                    .environmentObject(authManager) // Inject AuthManager
            } else {
                LoginView()
                    .environmentObject(authManager) // Inject AuthManager
            }
        }
    }
}




