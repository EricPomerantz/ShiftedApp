//
//  EditListingView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/9/24.
//

import SwiftUI

struct EditListingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var listing: Listing

    private let listingService = ListingService()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Listing Details")) {
                    TextField("Title", text: $listing.title)
                    TextField("Description", text: $listing.description)
                    TextField("Price", value: $listing.price, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }

                Button(action: updateListing) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Edit Listing")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func updateListing() {
        listingService.updateListing(listing) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to update listing.")
            }
        }
    }
}
