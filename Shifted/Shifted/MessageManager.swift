//
//  MessageManager.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/10/24.
//

import FirebaseFirestore
import FirebaseAuth

class MessageManager: ObservableObject {
    @Published var messages: [Message] = []

    private let db = Firestore.firestore()

    func fetchMessages(for chatId: String) {
        print("Debug: Fetching messages for chatId: \(chatId)")
        db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No messages found for chatId: \(chatId).")
                    return
                }

                print("Debug: Fetched \(documents.count) document(s) for chatId: \(chatId).")

                self.messages = documents.compactMap { document in
                    print("Debug: Raw message data: \(document.data())") // Log raw data

                    do {
                        var message = try document.data(as: Message.self)
                        message.id = document.documentID // Add the document ID as the message ID
                        print("Debug: Successfully decoded message: \(message)")
                        return message
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                        print("CodingPath: \(context.codingPath)")
                        return nil
                    } catch let DecodingError.typeMismatch(type, context) {
                        print("Type '\(type)' mismatch: \(context.debugDescription)")
                        print("CodingPath: \(context.codingPath)")
                        return nil
                    } catch {
                        print("Error decoding message: \(error.localizedDescription)")
                        return nil
                    }
                }

                print("Debug: Successfully fetched \(self.messages.count) messages.")
            }
    }

    func sendMessage(to chatId: String, content: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: User not authenticated.")
            return
        }

        let message: [String: Any] = [
            "id": UUID().uuidString,
            "text": content,
            "timestamp": Timestamp(),
            "username": currentUser.email ?? "Unknown"
        ]

        print("Debug: Sending message: \(message) to chatId: \(chatId)")

        db.collection("chats").document(chatId).collection("messages").addDocument(data: message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully to chatId: \(chatId).")

                // Update the lastMessage field in the chat document
                self.updateLastMessage(for: chatId, content: content)
            }
        }
    }

    private func updateLastMessage(for chatId: String, content: String) {
        db.collection("chats").document(chatId).updateData([
            "lastMessage": content
        ]) { error in
            if let error = error {
                print("Error updating lastMessage: \(error.localizedDescription)")
            } else {
                print("Successfully updated lastMessage for chatId: \(chatId).")
            }
        }
    }
}

