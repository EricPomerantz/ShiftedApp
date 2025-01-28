//
//  ProfileView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/8/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Picture
                Circle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .overlay(
                        Text(authManager.user?.displayName?.prefix(1).uppercased() ?? "U")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
                
                // User Information
                Text(authManager.user?.displayName ?? "Unknown User")
                    .font(.title)
                    .bold()
                Text("Car Enthusiast • Joined \(formattedJoinDate())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Logout Button
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }

    private func formattedJoinDate() -> String {
        guard let date = authManager.user?.metadata.creationDate else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthManager())
    }
}
