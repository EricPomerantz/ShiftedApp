//
//  CreateListingView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/9/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct CreateListingView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var category: String = "Cars"
    private let categories = ["Cars", "Parts", "Accessories"]

    @State private var selectedImages: [UIImage] = []
    @State private var imageUploadURLs: [String] = []

    @State private var isUploading = false // Track upload status
    @State private var showImagePicker = false // Show image picker

    @Environment(\.presentationMode) var presentationMode

    private let listingService = ListingService() // Use ListingService

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Listing Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                }

                Section(header: Text("Images")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()

                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Add Images")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                if isUploading {
                    ProgressView("Uploading Images...")
                }

                Button(action: saveListing) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Create Listing")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $selectedImages) // Custom ImagePicker
            }
        }
    }

    private func saveListing() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: User is not authenticated.")
            return
        }

        guard !title.isEmpty, !price.isEmpty else {
            print("Error: Title or price is empty.")
            return
        }

        isUploading = true

        uploadImages { urls in
            imageUploadURLs = urls
            print("Image URLs to save: \(imageUploadURLs)")

            let listing = Listing(
                id: UUID().uuidString,
                title: title,
                description: description,
                price: Double(price) ?? 0.0,
                images: imageUploadURLs,
                category: category,
                sellerId: currentUserId,
                createdAt: Date(),
                sellerName: "Seller's Name" // Replace with actual seller's name logic
            )

            print("Listing prepared for Firestore: \(listing)")

            listingService.saveListing(listing) { success, message in
                isUploading = false
                if success {
                    print("Listing saved successfully: \(listing)")
                    presentationMode.wrappedValue.dismiss()
                } else {
                    print("Failed to save listing to Firestore: \(message ?? "Unknown error")")
                }
            }
        }
    }

    private func uploadImages(completion: @escaping ([String]) -> Void) {
        let storage = Storage.storage().reference()
        var uploadedURLs: [String] = []
        let dispatchGroup = DispatchGroup()

        for (index, image) in selectedImages.enumerated() {
            guard let resizedImage = image.resized(toWidth: 1024),
                  let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
                print("Error: Could not resize or compress image \(index + 1)")
                continue
            }

            let fileName = "images/\(UUID().uuidString).jpg"
            let imageRef = storage.child(fileName)

            dispatchGroup.enter()
            print("Uploading image \(index + 1)/\(selectedImages.count) to \(fileName)...")

            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image \(index + 1): \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                print("Upload complete for image \(index + 1). Retrieving download URL...")
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL for image \(index + 1): \(error.localizedDescription)")
                    } else if let url = url {
                        print("Successfully uploaded image \(index + 1): \(url.absoluteString)")
                        uploadedURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("All image uploads completed. URLs: \(uploadedURLs)")
            completion(uploadedURLs)
        }
    }
}

// Utility to resize images
extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
