import SwiftUI

struct CalorieTargetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var calorieTarget: Int
    let onSave: (Int) -> Void
    
    init(currentValue: Int, onSave: @escaping (Int) -> Void) {
        self._calorieTarget = State(initialValue: currentValue)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Calorie Target")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("Set your daily calorie goal")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Calorie display
                VStack(spacing: 8) {
                    Text("\(calorieTarget)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primaryOrange)
                    
                    Text("calories per day")
                        .font(.headline)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                }
                
                // Slider
                VStack(spacing: 16) {
                    HStack {
                        Text("1200")
                            .font(.caption)
                            .foregroundColor(AppColors.textCharcoal.opacity(0.6))
                        Spacer()
                        Text("3500")
                            .font(.caption)
                            .foregroundColor(AppColors.textCharcoal.opacity(0.6))
                    }
                    
                    Slider(value: Binding(
                        get: { Double(calorieTarget) },
                        set: { calorieTarget = Int($0) }
                    ), in: 1200...3500, step: 50)
                    .accentColor(AppColors.primaryOrange)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Save button
                Button("Save Changes") {
                    onSave(calorieTarget)
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
    CalorieTargetView(currentValue: 2200) { newValue in
        print("New calorie target: \(newValue)")
    }
} 