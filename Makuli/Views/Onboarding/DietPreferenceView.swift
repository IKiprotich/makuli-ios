import SwiftUI

struct DietPreferenceView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    
    private let dietOptions = [
        ("No restrictions", "leaf.fill"),
        ("Vegetarian", "carrot.fill"),
        ("Vegan", "leaf.circle.fill"),
        ("Keto", "flame.fill"),
        ("Paleo", "mountain.2.fill"),
        ("Mediterranean", "fish.fill"),
        ("Gluten-free", "xmark.circle.fill"),
        ("Dairy-free", "drop.fill")
    ]
    
    @State private var selectedDiets: [String] = []
    
    var body: some View {
        ZStack {
            AppColors.bgCream
            
            VStack(spacing: 30) {
                // Progress bar
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                // Title and subtitle
                VStack(spacing: 12) {
                    Text("Any dietary preferences?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("Select all that apply (optional)")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Diet selection grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(dietOptions, id: \.0) { option in
                            let isSelected = selectedDiets.contains(option.0)
                            
                            Button(action: {
                                // 1. Update UI state instantly
                                if isSelected {
                                    selectedDiets.removeAll { $0 == option.0 }
                                } else {
                                    selectedDiets.append(option.0)
                                }
                                // 2. Update shared model in background
                                DispatchQueue.main.async {
                                    onboardingData.dietaryPreferences = selectedDiets
                                }
                            }) {
                                VStack(spacing: 10) {
                                    Image(systemName: option.1)
                                        .font(.title2)
                                        .foregroundColor(isSelected ? .white : AppColors.successGreen)
                                    
                                    Text(option.0)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(isSelected ? .white : AppColors.textCharcoal)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .background(
                                    isSelected
                                    ? AppColors.successGreen
                                    : Color.white.opacity(0.95)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isSelected
                                            ? Color.clear
                                            : AppColors.textCharcoal.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 36)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    // 1. Advance page immediately
                    currentPage += 1
                    // 2. Save to onboardingData in background
                    DispatchQueue.main.async {
                        onboardingData.dietaryPreferences = selectedDiets
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primaryOrange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            selectedDiets = onboardingData.dietaryPreferences
        }
    }
}

#Preview {
    DietPreferenceView(
        onboardingData: OnboardingData(
            id: "id",
            userId: "userId",
            age: 25,
            gender: "Other",
            height: 170.0,
            weight: 70.0,
            activityLevel: "Moderately Active",
            fitnessGoal: "Maintain Weight",
            dietaryPreferences: [],
            budgetRange: "Medium",
            preferredCuisines: [],
            cookingSkillLevel: "Beginner",
            preferredPrepTime: 30,
            preferredServings: 2,
            allergies: [],
            favoriteIngredients: [],
            dislikedIngredients: [],
            includeMealPrep: true,
            includeShoppingList: true,
            includeNutritionInfo: true,
            rotateMeals: true,
            includeLeftovers: false,
            preferredComplexity: "Easy",
            additionalNotes: nil,
            isCompleted: false,
            currentStep: 1,
            totalSteps: 7,
            createdAt: Date(),
            updatedAt: Date()
        ),
        currentPage: .constant(3),
        totalPages: 7
    )
}
