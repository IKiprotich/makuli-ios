import SwiftUI

struct DislikesView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let dislikeOptions = [
        "Almonds", "Asparagus", "Avocado", "Banana", "Beans", "Beets", "Bell peppers", "Blue cheese", "Broccoli", "Brussels sprouts", "Cabbage", "Carrots", "Cauliflower", "Celery", "Cheese", "Cucumber", "Eggplant", "Fennel", "Garlic", "Ginger", "Kale", "Lamb", "Leek", "Lettuce", "Mushrooms", "Olives", "Onion", "Peas", "Pineapple", "Radish", "Spinach", "Squash", "Sweet potato", "Tomato", "Tofu", "Zucchini"
    ]
    
    var body: some View {
        ZStack {
            AppColors.bgCream.ignoresSafeArea()
            VStack(spacing: 30) {
                ProgressView(value: 7, total: 15)
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
                            let isSelected = onboardingData.dislikedIngredients.contains(item)
                            Button(action: {
                                if isSelected {
                                    onboardingData.dislikedIngredients.removeAll { $0 == item }
                                } else {
                                    onboardingData.dislikedIngredients.append(item)
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
                    currentPage += 1
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
    }
} 