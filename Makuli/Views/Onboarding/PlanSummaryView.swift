import SwiftUI

struct PlanSummaryView: View {
    @ObservedObject var onboardingData: OnboardingData
    @ObservedObject var onboardingViewModel: OnboardingViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var currentPage: Int
    let totalPages: Int
    var body: some View {
        ZStack {
            AppColors.bgCream
            VStack(spacing: 30) {
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 20) {
                    Text("Your plan is ready 🎉")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    if !onboardingData.avatarEmoji.isEmpty {
                        Text(onboardingData.avatarEmoji)
                            .font(.system(size: 48))
                    }
                    Text("\(onboardingData.calorieGoal ?? onboardingData.estimatedDailyCalories) kCal")
                        .font(.title)
                        .foregroundColor(AppColors.primaryOrange)
                    Text("Your meals have been adapted for your energy needs and goals.")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                Spacer()
                Button(action: {
                    // TODO: Save onboarding data and complete onboarding
                }) {
                    Text("Finish")
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
    }
} 