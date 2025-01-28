//
//  Chat.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/9/24.
//

import Foundation
import FirebaseFirestore

struct Chat: Identifiable, Codable {
    var id: String?
    var participants: [String]
    var lastMessage: String?
    @ServerTimestamp var createdAt: Date?
}

@propertyWrapper
struct ServerTimestamp: Codable {
    var wrappedValue: Date?

    init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let timestamp = try? container.decode(Timestamp.self) {
            self.wrappedValue = timestamp.dateValue()
        } else {
            self.wrappedValue = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}



//struct Message: Identifiable, Codable {
   // @DocumentID var id: String?
   // var senderId: String
   // var content: String
   // var timestamp: Date
//}


import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var timestamp: Date
    var username: String
}




