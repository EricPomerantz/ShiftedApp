//
//  Question.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/10/24.
//

import FirebaseFirestore

struct Question: Identifiable, Codable {
    @DocumentID var id: String? // Firestore auto-generated ID
    let title: String
    let description: String
    let createdAt: Date
    let creatorId: String
    let make: String
    let model: String
    let year: String
    let category: String?
}
