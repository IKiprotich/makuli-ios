import SwiftUI

struct ProfileDietPreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPreference: String
    let onSave: (String) -> Void
    
    private let dietOptions = [
        "Balanced",
        "Vegetarian",
        "Vegan",
        "Low Carb",
        "Keto",
        "Paleo",
        "Mediterranean",
        "Gluten Free"
    ]
    
    init(currentPreference: String, onSave: @escaping (String) -> Void) {
        self._selectedPreference = State(initialValue: currentPreference)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Diet Preference")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("Choose your dietary preference")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                // Diet options
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(dietOptions, id: \.self) { option in
                            Button(action: {
                                selectedPreference = option
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.headline)
                                        .foregroundColor(selectedPreference == option ? .white : AppColors.text)
                                    
                                    Spacer()
                                    
                                    if selectedPreference == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(selectedPreference == option ? AppColors.primaryOrange : Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedPreference == option ? AppColors.primaryOrange : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Save button
                Button("Save Changes") {
                    onSave(selectedPreference)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primaryOrange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryOrange)
                }
            }
        }
    }
}

#Preview {
    ProfileDietPreferenceView(currentPreference: "Balanced") { newPreference in
        print("New diet preference: \(newPreference)")
    }
} 