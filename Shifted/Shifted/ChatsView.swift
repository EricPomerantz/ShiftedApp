//
//  ChatsView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/8/24.
//

import SwiftUI
import FirebaseAuth

struct ChatsView: View {
    @State private var chats: [Chat] = []
    private let chatService = ChatService()
    @State private var userNames: [String: String] = [:] // Store fetched user names

    var body: some View {
        NavigationView {
            List {
                if chats.isEmpty {
                    Text("No conversations found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(chats, id: \.id) { chat in
                        NavigationLink(destination: ChatDetailView(chatId: chat.id ?? "UnknownChatId")) {
                            ChatRow(
                                userName: userNames[getOtherParticipantId(from: chat.participants) ?? "Unknown"] ?? "Unknown",
                                lastMessage: chat.lastMessage ?? "No message available"
                            )
                        }
                    }
                }
            }
            .navigationTitle("Chats")
            .onAppear {
                fetchChatsAndParticipantNames()
            }
        }
    }

    private func getOtherParticipantId(from participants: [String]) -> String? {
        let currentUserId = Auth.auth().currentUser?.uid
        return participants.first { $0 != currentUserId }
    }

    private func fetchChatsAndParticipantNames() {
        chatService.fetchChats { fetchedChats in
            DispatchQueue.main.async {
                self.chats = fetchedChats
                self.fetchParticipantNames(for: fetchedChats)
            }
        }
    }

    private func fetchParticipantNames(for chats: [Chat]) {
        for chat in chats {
            if let otherUserId = chat.participants.first(where: { $0 != Auth.auth().currentUser?.uid }),
               userNames[otherUserId] == nil { // Avoid redundant fetches
                chatService.fetchUserName(for: otherUserId) { name in
                    DispatchQueue.main.async {
                        userNames[otherUserId] = name ?? "Unknown"
                    }
                }
            }
        }
    }
}

struct ChatRow: View {
    let userName: String
    let lastMessage: String

    var body: some View {
        HStack {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
                .overlay(
                    Text(String(userName.prefix(1)))
                        .foregroundColor(.white)
                        .font(.headline)
                )

            VStack(alignment: .leading) {
                Text(userName)
                    .font(.headline)
                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}
