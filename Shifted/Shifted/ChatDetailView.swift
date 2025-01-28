//
//  ChatDetailView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/8/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatDetailView: View {
    let chatId: String
    @StateObject private var messageManager = MessageManager()
    @State private var newMessage: String = ""

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messageManager.messages) { message in
                            MessageRow(
                                text: message.text,
                                isOutgoing: message.username == Auth.auth().currentUser?.email
                            )
                        }
                    }
                    .padding()
                }

                SendMessageView { messageText in
                    messageManager.sendMessage(to: chatId, content: messageText)
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                messageManager.fetchMessages(for: chatId)
            }
        }
    }
}

struct MessageRow: View {
    let text: String
    let isOutgoing: Bool

    var body: some View {
        HStack {
            if isOutgoing {
                Spacer()
            }
            messageBubble
            if !isOutgoing {
                Spacer()
            }
        }
    }

    private var messageBubble: some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(isOutgoing ? .white : .primary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(isOutgoing ? Color.blue.gradient : Color(.systemGray5).gradient)
            )
            .padding(isOutgoing ? .trailing : .leading, 12)
    }
}

struct SendMessageView: View {
    var onSend: (String) -> Void
    @State private var messageText: String = ""

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField("Message", text: $messageText, axis: .vertical)
                .padding(.leading)
                .padding(.trailing, 4)
                .padding(.vertical, 8)

            Button {
                if !messageText.isEmpty {
                    onSend(messageText)
                    messageText = ""
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .bold()
                    .padding(4)
            }
            .disabled(messageText.isEmpty)
        }
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color(uiColor: .systemGray2)))
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thickMaterial)
    }
}
