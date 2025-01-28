//
//  LoginView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/7/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager // Shared AuthManager instance

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = "" // Added for sign-up
    @State private var lastName: String = ""  // Added for sign-up
    @State private var isLoginMode = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            // Title at the top
            Text("Shifted")
                .font(.custom("Snell Roundhand", size: 50)) // Cursive style font
                .foregroundColor(Color.black) 
                .padding(.bottom, 120)

            // Title for Login or Sign-Up
            Text(isLoginMode ? "Login" : "Sign Up")
                .font(.title)
                .bold()

            // First Name Field (only in sign-up mode)
            if !isLoginMode {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)

                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
            }

            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            // Action Button
            Button(action: handleAuth) {
                Text(isLoginMode ? "Login" : "Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            // Toggle Mode Button
            Button(action: {
                isLoginMode.toggle()
            }) {
                Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            Spacer()

            // Footer with name and Z number
            VStack {
                Text("Name: Eric Pomerantz")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text("Z Number: Z23605291")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20) // Add padding at the bottom
        }
        .padding()
    }

    private func handleAuth() {
        if email.isEmpty || password.isEmpty || (!isLoginMode && (firstName.isEmpty || lastName.isEmpty)) {
            errorMessage = "Please fill in all fields."
            return
        }

        if isLoginMode {
            authManager.signIn(email: email, password: password)
        } else {
            authManager.signUp(email: email, password: password, firstName: firstName, lastName: lastName)
        }
    }
}

