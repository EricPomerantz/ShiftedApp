//
//  ForumView.swift
//  Shifted
//
//  Created by Eric Poemrantz on 12/8/24.
//

import SwiftUI
import FirebaseFirestore

struct ForumView: View {
    @State private var questions: [Question] = []
    @State private var searchText = ""
    @State private var isFilterViewPresented = false
    @State private var isCreateQuestionViewPresented = false

    @State private var selectedYear = "All Years"
    @State private var selectedMake = "All Makes"
    @State private var selectedModel = "All Models"
    @State private var vinSearch = ""

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search questions...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: {
                        isFilterViewPresented = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20))
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                if isFilterApplied {
                    Button(action: clearFilter) {
                        Text("Clear Filter")
                            .font(.body)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                    }
                }

                List {
                    ForEach(filteredQuestions) { question in
                        NavigationLink(destination: QuestionDetailView(question: question)) {
                            QuestionRow(
                                title: question.title,
                                category: question.category ?? "General",
                                year: question.year ?? "N/A",
                                make: question.make ?? "N/A",
                                model: question.model ?? "N/A"
                            )
                        }
                    }
                }
                .navigationTitle("Forum")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isCreateQuestionViewPresented = true
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                        }
                    }
                }
                .onAppear {
                    fetchQuestions()
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("QuestionCreated"), object: nil, queue: .main) { _ in
                        fetchQuestions()
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("QuestionCreated"), object: nil)
                }
                .sheet(isPresented: $isFilterViewPresented) {
                    FilterView(
                        selectedYear: $selectedYear,
                        selectedMake: $selectedMake,
                        selectedModel: $selectedModel,
                        vinSearch: $vinSearch
                    )
                }
                .sheet(isPresented: $isCreateQuestionViewPresented) {
                    CreateQuestionView(onQuestionCreated: {
                        fetchQuestions()
                    })
                }
            }
        }
    }

    private var filteredQuestions: [Question] {
        questions.filter { question in
            (searchText.isEmpty || question.title.localizedCaseInsensitiveContains(searchText)) &&
            (selectedYear == "All Years" || question.year == selectedYear) &&
            (selectedMake == "All Makes" || question.make == selectedMake) &&
            (selectedModel == "All Models" || question.model == selectedModel)
        }
    }

    private var isFilterApplied: Bool {
        selectedYear != "All Years" || selectedMake != "All Makes" || selectedModel != "All Models"
    }

    private func clearFilter() {
        selectedYear = "All Years"
        selectedMake = "All Makes"
        selectedModel = "All Models"
        vinSearch = ""
        searchText = ""
    }

    func fetchQuestions() {
        db.collection("questions")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching questions: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    return
                }

                self.questions = documents.compactMap { document in
                    try? document.data(as: Question.self)
                }
            }
    }
}


struct QuestionRow: View {
    let title: String
    let category: String
    let year: String
    let make: String
    let model: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(year) \(make) \(model)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
