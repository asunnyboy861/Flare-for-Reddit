import SwiftUI

struct ContactSupportView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var selectedSubject = "General"
    @State private var customSubject = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let subjects = [
        "General",
        "Feature Suggestion",
        "Bug Report",
        "Usage Question",
        "Performance Issue",
        "UI Improvement",
        "Other"
    ]

    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"

    var body: some View {
        Form {
            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(subjects, id: \.self) { subject in
                        Button(action: { selectedSubject = subject }) {
                            Text(subject)
                                .font(.subheadline.weight(selectedSubject == subject ? .semibold : .regular))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .frame(minWidth: 80)
                                .background(selectedSubject == subject ? Color.adaptivePrimary : Color.adaptiveSurface)
                                .foregroundColor(selectedSubject == subject ? .white : .adaptiveText2)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if selectedSubject == "Other" {
                    TextField("Custom subject", text: $customSubject)
                        .textFieldStyle(.roundedBorder)
                }
            } header: {
                Text("Subject")
            }

            Section {
                TextField("Your name", text: $name)
                TextField("Email address", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            } header: {
                Text("Message")
            }

            Section {
                Button(action: submitFeedback) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Submit Feedback")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.adaptivePrimary)
                .disabled(isSubmitting || !isValid)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.adaptiveError)
                        .font(.caption)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.adaptiveBackground)
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") {
                name = ""; email = ""; message = ""; customSubject = ""
                selectedSubject = "General"
            }
        } message: {
            Text("Your feedback has been submitted successfully.")
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitFeedback() {
        guard isValid else { return }
        isSubmitting = true
        errorMessage = nil

        let subjectValue = selectedSubject == "Other" ? customSubject : selectedSubject

        let body: [String: String] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces),
            "subject": subjectValue,
            "message": message.trimmingCharacters(in: .whitespaces),
            "app_name": "Flare for Reddit"
        ]

        guard let url = URL(string: "\(backendURL)/api/feedback") else {
            errorMessage = "Invalid server URL"
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            errorMessage = "Failed to prepare request"
            isSubmitting = false
            return
        }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    showSuccess = true
                } else {
                    errorMessage = "Failed to submit. Please try again."
                }
            }
        }.resume()
    }
}
