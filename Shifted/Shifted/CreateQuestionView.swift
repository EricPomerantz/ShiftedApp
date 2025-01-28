//
//  CreateQuestionView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/9/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreateQuestionView: View {
    @Environment(\.presentationMode) var presentationMode
    var onQuestionCreated: (() -> Void)?

    @State private var title = ""
    @State private var description = ""
    @State private var selectedYear = "All Years"
    @State private var selectedMake = "All Makes"
    @State private var selectedModel = "All Models"
    @State private var selectedCategory = "General"

    @State private var years: [String] = ["All Years"] + (1900...2025).map { "\($0)" }.reversed()
    @State private var makes: [String] = ["All Makes", "Honda", "Toyota", "Ford", "Chevrolet", "BMW", "Mercedes-Benz"]
    @State private var models: [String] = ["All Models"]
    @State private var isLoading = false

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(["General", "Maintenance", "Performance"], id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }

                Section(header: Text("Car Details")) {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .onChange(of: selectedYear) { _ in fetchModels() }

                    Picker("Make", selection: $selectedMake) {
                        ForEach(makes, id: \.self) { make in
                            Text(make).tag(make)
                        }
                    }
                    .onChange(of: selectedMake) { _ in fetchModels() }

                    if isLoading {
                        ProgressView("Loading Models...")
                    } else {
                        Picker("Model", selection: $selectedModel) {
                            ForEach(models, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                    }
                }

                Button(action: saveQuestion) {
                    Text("Post Question")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Ask a Question")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func fetchModels() {
        guard selectedMake != "All Makes", selectedYear != "All Years" else {
            DispatchQueue.main.async {
                self.models = ["All Models"]
            }
            return
        }

        let formattedMake = selectedMake.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? selectedMake
        let urlString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/\(formattedMake)/modelyear/\(selectedYear)?format=json"

        guard let url = URL(string: urlString) else { return }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                print("Error fetching models: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }

            do {
                let decodedResponse = try JSONDecoder().decode(ModelResponse.self, from: data)
                DispatchQueue.main.async {
                    self.models = ["All Models"] + decodedResponse.Results.compactMap { $0.Model_Name }
                }
            } catch {
                print("Error decoding models: \(error)")
            }
        }.resume()
    }

    private func saveQuestion() {
        guard !title.isEmpty else {
            print("Title is required")
            return
        }

        let questionData: [String: Any] = [
            "title": title,
            "description": description,
            "category": selectedCategory,
            "year": selectedYear,
            "make": selectedMake,
            "model": selectedModel,
            "createdAt": Timestamp(),
            "creatorId": Auth.auth().currentUser?.uid ?? ""
        ]

        db.collection("questions").addDocument(data: questionData) { error in
            if let error = error {
                print("Error saving question: \(error.localizedDescription)")
            } else {
                print("Question saved successfully.")
                onQuestionCreated?()
                NotificationCenter.default.post(name: NSNotification.Name("QuestionCreated"), object: nil)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ModelResponse: Codable {
    struct Result: Codable {
        let Model_Name: String
    }
    let Results: [Result]
}
