//
//  ListingDetailView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/7/24.
//

import SwiftUI
import FirebaseAuth

struct ListingDetailView: View {
    @State private var sellerName: String = "Loading..."
    @State private var showEditView: Bool = false
    @State private var showChatDetail: Bool = false // Binding for NavigationLink
    @State private var chatId: String? = nil // Store the created chat ID
    @Environment(\.presentationMode) var presentationMode

    let listing: Listing
    private let chatService = ChatService()
    private let listingService = ListingService()

    var body: some View {
        VStack {
            if let imageUrl = listing.images.first, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    default:
                        ProgressView()
                    }
                }
                .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.largeTitle)
                    .padding(.top)

                Text("Seller: \(sellerName)")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(listing.description)
                    .padding(.top)

                Text("$\(String(format: "%.2f", listing.price))")
                    .font(.title)
                    .bold()
                    .padding(.top)
            }
            .padding()

            Spacer()

            // Edit and Delete Buttons if user is the owner
            if isCurrentUserOwner() {
                HStack {
                    Button(action: {
                        showEditView = true
                    }) {
                        Text("Edit Listing")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: deleteListing) {
                        Text("Delete Listing")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            } else {
                // Message Seller Button
                Button(action: {
                    initiateChat()
                }) {
                    Text("Message Seller")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }

            // NavigationLink for ChatDetailView
            NavigationLink(
                destination: ChatDetailView(chatId: chatId ?? ""),
                isActive: $showChatDetail
            ) {
                EmptyView()
            }

            // NavigationLink for EditListingView
            NavigationLink(
                destination: EditListingView(listing: listing),
                isActive: $showEditView
            ) {
                EmptyView()
            }
        }
        .onAppear(perform: fetchSellerName)
        .navigationTitle(listing.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func fetchSellerName() {
        chatService.fetchUserName(for: listing.sellerId) { name in
            DispatchQueue.main.async {
                self.sellerName = name ?? "Unknown"
            }
        }
    }

    private func initiateChat() {
        guard let currentUserId = Auth.auth().currentUser?.uid, currentUserId != listing.sellerId else {
            print("Cannot chat with yourself.")
            return
        }

        chatService.createChat(with: listing.sellerId, firstMessage: "Hi! Is this still available?") { chatId in
            if let chatId = chatId {
                DispatchQueue.main.async {
                    self.chatId = chatId
                    self.showChatDetail = true
                }
            } else {
                print("Failed to create chat.")
            }
        }
    }

    private func isCurrentUserOwner() -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return false
        }
        return currentUserId == listing.sellerId
    }

    private func deleteListing() {
        // Use the `id` property directly
        listingService.deleteListing(listing.id) { success in
            if success {
                print("Listing deleted successfully.")
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to delete listing.")
            }
        }
    }


}



