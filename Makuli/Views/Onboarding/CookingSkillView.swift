import SwiftUI

struct CookingSkillView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    
    private let skillOptions = [
        ("Novice", "I think I know where the microwave is"),
        ("Beginner", "Comfortable with simple recipes"),
        ("Intermediate", "Comfortable with most recipes"),
        ("Advanced", "I should be on MasterChef")
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
                    Text("Cooking skills")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    Text("How would you rate your cooking skills?")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                VStack(spacing: 16) {
                    ForEach(skillOptions, id: \.0) { option in
                        let isSelected = onboardingData.cookingSkillLevel == option.0
                        Button(action: {
                            onboardingData.cookingSkillLevel = option.0
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.0)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : AppColors.textCharcoal)
                                Text(option.1)
                                    .font(.caption)
                                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.textCharcoal.opacity(0.6))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                Spacer()
                Button(action: {
                    if !onboardingData.cookingSkillLevel.isEmpty {
                        currentPage += 1
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!onboardingData.cookingSkillLevel.isEmpty ? AppColors.primaryOrange : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                }
                .disabled(onboardingData.cookingSkillLevel.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
    }
} 