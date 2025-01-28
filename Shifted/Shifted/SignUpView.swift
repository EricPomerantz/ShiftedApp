//
//  SignUpView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/8/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Create an Account")
                .font(.largeTitle)
                .bold()

            // First Name Field
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)

            // Last Name Field
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)

            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Confirm Password Field
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            // Sign-Up Button
            Button(action: handleSignUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }

    private func handleSignUp() {
        if email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }

        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }

        authManager.signUp(email: email, password: password, firstName: firstName, lastName: lastName)
    }
}


#Preview {
    SignUpView()
}
