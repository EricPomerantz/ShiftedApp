//
//  QuestionDetailView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/10/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct QuestionDetailView: View {
    let question: Question
    @State private var answers: [Answer] = []
    @State private var newAnswer: String = ""

    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            Text(question.title)
                .font(.largeTitle)
                .bold()
            Text(question.description)
                .font(.body)
                .padding(.bottom)

            List(answers) { answer in
                VStack(alignment: .leading) {
                    Text(answer.text)
                        .font(.body)
                    HStack {
                        Text("Upvotes: \(answer.upvotes)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            upvoteAnswer(answer)
                        }) {
                            Text("Upvote")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }

            // New Answer Input
            HStack {
                TextField("Write your answer...", text: $newAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Post") {
                    addAnswer()
                }
                .disabled(newAnswer.isEmpty)
            }
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            fetchAnswers()
        }
    }

    // Fetch answers
    private func fetchAnswers() {
        db.collection("questions").document(question.id ?? "").collection("answers")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching answers: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                self.answers = documents.compactMap { try? $0.data(as: Answer.self) }
            }
    }

    // Add a new answer
    private func addAnswer() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let answer = Answer(
            id: nil,
            creatorId: currentUserId,
            text: newAnswer,
            createdAt: Date()
        )
        db.collection("questions").document(question.id ?? "").collection("answers")
            .addDocument(data: answer.asDictionary()) { error in
                if let error = error {
                    print("Error adding answer: \(error.localizedDescription)")
                } else {
                    self.newAnswer = ""
                }
            }
    }

    // Upvote an answer
    private func upvoteAnswer(_ answer: Answer) {
        guard let answerId = answer.id else { return }
        db.collection("questions").document(question.id ?? "").collection("answers")
            .document(answerId)
            .updateData(["upvotes": answer.upvotes + 1]) { error in
                if let error = error {
                    print("Error upvoting answer: \(error.localizedDescription)")
                }
            }
    }
}
