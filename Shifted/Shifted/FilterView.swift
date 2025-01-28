//
//  FilterView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/8/24.
//

import SwiftUI

struct FilterView: View {
    @Binding var selectedYear: String
    @Binding var selectedMake: String
    @Binding var selectedModel: String
    @Binding var vinSearch: String

    @Environment(\.presentationMode) var presentationMode

    @State private var years: [String] = ["All Years"] + (1900...2025).map { "\($0)" }.reversed()
    @State private var makes: [String] = ["All Makes", "Honda", "Toyota", "Ford", "Chevrolet", "BMW", "Mercedes-Benz"]
    @State private var models: [String] = ["All Models"]
    @State private var isLoading = false // Track loading state for models
    @State private var decodedVINData: [String: String] = [:]
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                // Year Picker
                Section(header: Text("Select Year")) {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .onChange(of: selectedYear) { _ in
                        fetchModels() // Fetch models when year changes
                    }
                }

                // Make Picker
                Section(header: Text("Select Make")) {
                    Picker("Make", selection: $selectedMake) {
                        ForEach(makes, id: \.self) { make in
                            Text(make).tag(make)
                        }
                    }
                    .onChange(of: selectedMake) { _ in
                        fetchModels() // Fetch models when make changes
                    }
                }

                // Model Picker
                Section(header: Text("Select Model")) {
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

                // VIN Search and Decoding
                Section(header: Text("Search by VIN")) {
                    TextField("Enter VIN", text: $vinSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.allCharacters)

                    Button("Decode VIN") {
                        decodeVIN()
                    }
                    .disabled(vinSearch.isEmpty)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                // Display Decoded VIN Data
                if !decodedVINData.isEmpty {
                    Section(header: Text("Decoded VIN Data")) {
                        ForEach(decodedVINData.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(key.capitalized)
                                Spacer()
                                Text(decodedVINData[key] ?? "N/A")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Listings")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Apply") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
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

    private func decodeVIN() {
        let baseURL = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/\(vinSearch)?format=json"
        guard let url = URL(string: baseURL) else {
            errorMessage = "Invalid VIN URL."
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to decode VIN: \(error.localizedDescription)"
                    self.decodedVINData = [:]
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received from VIN API."
                    self.decodedVINData = [:]
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json["Results"] as? [[String: Any]] {
                        var decodedData: [String: String] = [:]
                        for item in results {
                            if let variable = item["Variable"] as? String,
                               let value = item["Value"] as? String {
                                decodedData[variable] = value
                            }
                        }
                        self.decodedVINData = decodedData
                        self.errorMessage = nil

                        // Update selected filters with decoded VIN data
                        if let year = decodedData["Model Year"] {
                            self.selectedYear = year
                        }
                        if let make = decodedData["Make"] {
                            self.selectedMake = make
                        }
                        if let model = decodedData["Model"] {
                            self.selectedModel = model
                        }

                    } else {
                        self.errorMessage = "Unexpected response format."
                        self.decodedVINData = [:]
                    }
                } catch {
                    self.errorMessage = "Error parsing VIN response: \(error.localizedDescription)"
                    self.decodedVINData = [:]
                }
            }
        }.resume()
    }
}



struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            selectedYear: .constant("All Years"),
            selectedMake: .constant("All Makes"),
            selectedModel: .constant("All Models"),
            vinSearch: .constant("")
        )
    }
}

