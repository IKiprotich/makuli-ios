import SwiftUI

struct FavoriteCuisinesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCuisines: [String]
    let onSave: ([String]) -> Void
    
    private let cuisineOptions = [
        "American", "Mediterranean", "Mexican", "Asian", "Italian", "Chinese", "Indian", "Japanese", "Thai", "French", "Greek", "Spanish", "Korean", "Vietnamese", "Middle Eastern", "Caribbean", "African", "Latin American"
    ]
    
    init(currentCuisines: [String], onSave: @escaping ([String]) -> Void) {
        self._selectedCuisines = State(initialValue: currentCuisines)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Favorite Cuisines")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("Select cuisines you enjoy")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                // Cuisines grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(cuisineOptions, id: \.self) { cuisine in
                            let isSelected = selectedCuisines.contains(cuisine)
                            Button(action: {
                                if isSelected {
                                    selectedCuisines.removeAll { $0 == cuisine }
                                } else {
                                    selectedCuisines.append(cuisine)
                                }
                            }) {
                                Text(cuisine)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : AppColors.text)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
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
                }
                
                // Save button
                Button("Save Changes") {
                    onSave(selectedCuisines)
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
    FavoriteCuisinesView(currentCuisines: ["Italian", "Mexican"]) { newCuisines in
        print("New favorite cuisines: \(newCuisines)")
    }
} 