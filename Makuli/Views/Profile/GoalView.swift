import SwiftUI

struct GoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGoal: String
    let onSave: (String) -> Void
    
    private let goalOptions = [
        ("Lose Weight", "Scale down and feel great"),
        ("Gain Weight", "Build mass and strength"),
        ("Maintain Weight", "Stay healthy and balanced"),
        ("Build Muscle", "Gain lean muscle mass"),
        ("Improve Health", "Better nutrition overall")
    ]
    
    init(currentGoal: String, onSave: @escaping (String) -> Void) {
        self._selectedGoal = State(initialValue: currentGoal)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Fitness Goal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("What's your main goal?")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Goal options
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(goalOptions, id: \.0) { option in
                            Button(action: {
                                selectedGoal = option.0
                            }) {
                                HStack(spacing: 15) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.0)
                                            .font(.headline)
                                            .foregroundColor(selectedGoal == option.0 ? .white : AppColors.textCharcoal)
                                        
                                        Text(option.1)
                                            .font(.caption)
                                            .foregroundColor(selectedGoal == option.0 ? .white.opacity(0.8) : AppColors.textCharcoal.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedGoal == option.0 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(selectedGoal == option.0 ? AppColors.primaryOrange : Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedGoal == option.0 ? AppColors.primaryOrange : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Save button
                Button("Save Changes") {
                    onSave(selectedGoal)
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
            .background(AppColors.bgCream)
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
    GoalView(currentGoal: "Lose Weight") { newGoal in
        print("New goal: \(newGoal)")
    }
} 