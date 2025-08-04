import SwiftUI

struct MealsPerDayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMeals: Int
    let onSave: (Int) -> Void
    
    private let mealOptions = [1, 2, 3, 4, 5, 6]
    
    init(currentMeals: Int, onSave: @escaping (Int) -> Void) {
        self._selectedMeals = State(initialValue: currentMeals)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Meals Per Day")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("How many meals do you eat per day?")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Meals display
                VStack(spacing: 8) {
                    Text("\(selectedMeals)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primaryOrange)
                    
                    Text("meal\(selectedMeals == 1 ? "" : "s") per day")
                        .font(.headline)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                }
                
                // Meal options
                VStack(spacing: 12) {
                    ForEach(mealOptions, id: \.self) { meals in
                        let isSelected = selectedMeals == meals
                        Button(action: {
                            selectedMeals = meals
                        }) {
                            HStack {
                                Text("\(meals) meal\(meals == 1 ? "" : "s")")
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : AppColors.textCharcoal)
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(isSelected ? AppColors.primaryOrange : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? AppColors.primaryOrange : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Save button
                Button("Save Changes") {
                    onSave(selectedMeals)
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
    MealsPerDayView(currentMeals: 3) { newMeals in
        print("New meals per day: \(newMeals)")
    }
} 