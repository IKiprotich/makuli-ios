import SwiftUI

struct DislikesView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    @State private var selectedDislikes: [String] = []
    
    private let dislikeOptions = [
        "Almonds", "Asparagus", "Avocado", "Banana", "Beans", "Beets", "Bell peppers", "Blue cheese", "Broccoli", "Brussels sprouts", "Cabbage", "Carrots", "Cauliflower", "Celery", "Cheese", "Cucumber", "Eggplant", "Fennel", "Garlic", "Ginger", "Kale", "Lamb", "Leek", "Lettuce", "Mushrooms", "Olives", "Onion", "Peas", "Pineapple", "Radish", "Spinach", "Squash", "Sweet potato", "Tomato", "Tofu", "Zucchini"
    ]
    
    var body: some View {
        ZStack {
            AppColors.bgCream
            VStack(spacing: 30) {
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Dislikes")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    Text("Any dislikes?")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(dislikeOptions, id: \.self) { item in
                            let isSelected = selectedDislikes.contains(item)
                            Button(action: {
                                // 1. Update UI state instantly
                                if isSelected {
                                    selectedDislikes.removeAll { $0 == item }
                                } else {
                                    selectedDislikes.append(item)
                                }
                                // 2. Update shared model in background
                                DispatchQueue.main.async {
                                    onboardingData.dislikedIngredients = selectedDislikes
                                }
                            }) {
                                Text(item)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : AppColors.textCharcoal)
                                    .padding(.vertical, 14)
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
                    .padding(.horizontal, 24)
                }
                Spacer()
                Button(action: {
                    // 1. Advance page immediately
                    currentPage += 1
                    // 2. Save to onboardingData in background
                    DispatchQueue.main.async {
                        onboardingData.dislikedIngredients = selectedDislikes
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
            selectedDislikes = onboardingData.dislikedIngredients
        }
    }
} 