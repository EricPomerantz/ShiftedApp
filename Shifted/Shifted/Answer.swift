//
//  Answer.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/10/24.
//

import FirebaseFirestore

struct Answer: Identifiable, Codable {
    @DocumentID var id: String? // Firestore auto-generated ID
    let creatorId: String
    let text: String
    let createdAt: Date
    var upvotes: Int = 0 // Default value for upvotes

    // Convert to dictionary for Firestore
    func asDictionary() -> [String: Any] {
        return [
            "creatorId": creatorId,
            "text": text,
            "createdAt": Timestamp(date: createdAt),
            "upvotes": upvotes
        ]
    }
}


