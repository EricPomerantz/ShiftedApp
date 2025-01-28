//
//  ListingService.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/9/24.
//

import FirebaseFirestore
import FirebaseAuth

class ListingService {
    private let db = Firestore.firestore()

    // Fetch all listings
    func fetchListings(completion: @escaping ([Listing]) -> Void) {
        db.collection("listings")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching listings: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let listings = snapshot?.documents.compactMap { document -> Listing? in
                    do {
                        var listing = try document.data(as: Listing.self)
                        listing.id = document.documentID
                        return listing
                    } catch {
                        print("Error decoding document: \(document.documentID), \(error.localizedDescription)")
                        return nil
                    }
                } ?? []

                completion(listings)
            }
    }

    // Save a new listing
    func saveListing(_ listing: Listing, completion: @escaping (Bool, String?) -> Void) {
        var listing = listing // Mutable copy to update ID
        let collectionRef = db.collection("listings")

        do {
            let documentRef = collectionRef.document() // Pre-create document reference
            listing.id = documentRef.documentID // Assign generated ID to listing

            try documentRef.setData(from: listing) { error in
                if let error = error {
                    print("Error saving listing: \(error.localizedDescription)")
                    completion(false, "Error saving listing: \(error.localizedDescription)")
                } else {
                    completion(true, documentRef.documentID)
                }
            }
        } catch {
            print("Error serializing listing: \(error.localizedDescription)")
            completion(false, "Error serializing listing: \(error.localizedDescription)")
        }
    }

    // Update an existing listing
    func updateListing(_ listing: Listing, completion: @escaping (Bool) -> Void) {
        guard !listing.id.isEmpty else {
            print("Error: Listing ID is empty.")
            completion(false)
            return
        }

        do {
            try db.collection("listings").document(listing.id).setData(from: listing) { error in
                if let error = error {
                    print("Error updating listing: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } catch {
            print("Error serializing listing: \(error.localizedDescription)")
            completion(false)
        }
    }

    // Delete a listing
    func deleteListing(_ listingId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: User is not authenticated.")
            completion(false)
            return
        }

        let documentRef = db.collection("listings").document(listingId)

        documentRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching document before delete: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = snapshot?.data(), let sellerId = data["sellerId"] as? String else {
                print("Error: Document data missing or sellerId not found.")
                completion(false)
                return
            }

            if sellerId != currentUserId {
                print("Error: User is not the owner of the listing.")
                completion(false)
                return
            }

            documentRef.delete { error in
                if let error = error {
                    print("Error deleting listing: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
