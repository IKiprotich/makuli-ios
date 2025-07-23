import SwiftUI

struct PantryStatusView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let pantryOptions = [
        ("Basic", "I only have salt & pepper, olive oil"),
        ("Average", "I have common spices and seasonings"),
        ("Well-stocked", "I'm basically a grocery store at this point")
    ]
    
    var body: some View {
        ZStack {
            AppColors.bgCream.ignoresSafeArea()
            VStack(spacing: 30) {
                ProgressView(value: 13, total: 15)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Your pantry")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    Text("How well-stocked is your kitchen?")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                VStack(spacing: 16) {
                    ForEach(pantryOptions, id: \.0) { option in
                        let isSelected = onboardingData.pantryStatus == option.0
                        Button(action: {
                            onboardingData.pantryStatus = option.0
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
                    if !onboardingData.pantryStatus.isEmpty {
                        currentPage += 1
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!onboardingData.pantryStatus.isEmpty ? AppColors.primaryOrange : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                }
                .disabled(onboardingData.pantryStatus.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
} 