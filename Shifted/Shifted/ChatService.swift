//
//  ChatService.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/9/24.
//

import FirebaseFirestore
import FirebaseAuth

class ChatService {
    private let db = Firestore.firestore()

    // Create a chat
    func createChat(with userId: String, firstMessage: String, completion: @escaping (String?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            completion(nil)
            return
        }

        let participants = [currentUserId, userId].sorted()
        let chatId = participants.joined(separator: "_") // Unique chat ID

        let chatData: [String: Any] = [
            "participants": participants,
            "createdAt": Timestamp(),
            "lastMessage": firstMessage
        ]

        let chatRef = db.collection("chats").document(chatId)

        chatRef.setData(chatData) { error in
            if let error = error {
                print("Error creating chat: \(error.localizedDescription)")
                completion(nil)
            } else {
                print("Chat created with ID: \(chatId)")

                // Add the first message to the messages collection
                let message: [String: Any] = [
                    "id": UUID().uuidString,
                    "text": firstMessage,
                    "timestamp": Timestamp(),
                    "username": Auth.auth().currentUser?.email ?? "Unknown"
                ]

                chatRef.collection("messages").addDocument(data: message) { error in
                    if let error = error {
                        print("Error adding the first message: \(error.localizedDescription)")
                    } else {
                        print("First message added successfully to chatId: \(chatId).")
                    }
                }

                completion(chatId)
            }
        }
    }

    // Fetch chats
    func fetchChats(completion: @escaping ([Chat]) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            completion([])
            return
        }

        print("Debug: Fetching chats for user \(currentUserId)")
        db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("Debug: No documents found.")
                    completion([])
                    return
                }

                print("Debug: Fetched \(documents.count) document(s).")
                let chats = documents.compactMap { document -> Chat? in
                    print("Debug: Attempting to decode document \(document.documentID)")
                    do {
                        var chat = try document.data(as: Chat.self)
                        chat.id = document.documentID // Assign document ID to chat
                        print("Debug: Successfully decoded chat with ID: \(chat.id ?? "Unknown")")
                        return chat
                    } catch {
                        print("Error decoding chat \(document.documentID): \(error)")
                        return nil
                    }
                }

                print("Debug: Fetched \(chats.count) valid chat(s).")
                completion(chats)
            }
    }

    // Fetch user name
    func fetchUserName(for userId: String, completion: @escaping (String?) -> Void) {
        print("Debug: Fetching user name for user ID \(userId)")
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user name: \(error.localizedDescription)")
                completion(nil)
            } else if let data = document?.data() {
                print("Debug: Fetched user data: \(data)")
                let firstName = data["firstName"] as? String
                let lastName = data["lastName"] as? String
                let fullName = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
                completion(fullName.isEmpty ? nil : fullName)
            } else {
                print("Debug: User document not found.")
                completion(nil)
            }
        }
    }
}

