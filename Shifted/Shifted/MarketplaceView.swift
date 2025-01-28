//
//  MarketplaceView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/7/24.
//

import SwiftUI
import FirebaseFirestore

struct MarketplaceView: View {
    @State private var listings: [Listing] = [] // Fetched listings
    @State private var searchText = ""
    @State private var isLoading = true // Track loading state

    private let db = Firestore.firestore() // Firestore database reference

    var filteredListings: [Listing] {
        if searchText.isEmpty {
            return listings
        } else {
            return listings.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("Marketplace")
                    .font(Font.custom("Georgia-Bold", size: 36)) // Change font to a more fancy one
                                        .foregroundColor(.gray) // Optional: Add color to the title
                                        .padding(.top, 16)

                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)

                // Content
                if isLoading {
                    ProgressView("Loading Listings...")
                        .padding()
                } else if filteredListings.isEmpty {
                    Text("No listings found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    ListingCardView(listing: listing)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .padding(.horizontal)
            .onAppear(perform: setupListener)
        }
    }

    // Real-time Firestore listener
    private func setupListener() {
        isLoading = true

        db.collection("listings")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching listings: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No listings found.")
                    self.isLoading = false
                    return
                }

                let fetchedListings: [Listing] = documents.compactMap { document in
                    do {
                        return try document.data(as: Listing.self)
                    } catch {
                        print("Error decoding listing: \(error.localizedDescription)")
                        return nil
                    }
                }

                print("Marketplace updated: \(fetchedListings.count) listings fetched.")
                self.listings = fetchedListings
                self.isLoading = false
            }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search listings...", text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Display the first image as a large thumbnail
            if let thumbnailURL = listing.images.first, !thumbnailURL.isEmpty {
                AsyncImage(url: URL(string: thumbnailURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        Color.gray
                            .frame(height: 200)
                    default:
                        ProgressView()
                            .frame(height: 200)
                    }
                }
            } else {
                Color.gray
                    .frame(height: 200)
            }

            // Title, price, and description
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)

                Text("$\(String(format: "%.2f", listing.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(listing.description)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.gray)
            }
            .padding([.leading, .trailing, .bottom], 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Preview for development
#Preview {
    MarketplaceView()
}
