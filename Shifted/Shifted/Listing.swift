//
//  Listing.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/7/24.
//

import Foundation

struct Listing: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var price: Double
    var images: [String] // URLs of images stored in Firebase
    var category: String
    var sellerId: String
    var createdAt: Date
    var sellerName: String
}
