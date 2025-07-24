import SwiftUI

struct EnergyNeedsView: View {
    @ObservedObject var onboardingData: OnboardingData
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
                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.primaryOrange)
                    Text("Energy needs")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    Text("The next questions will help us calculate your daily energy needs")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
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
        .ignoresSafeArea()
    }
} 