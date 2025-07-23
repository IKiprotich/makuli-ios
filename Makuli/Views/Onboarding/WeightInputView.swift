import SwiftUI

struct WeightInputView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    @State private var selectedWeight: Double = 75.0
    var body: some View {
        ZStack {
            AppColors.bgCream.ignoresSafeArea()
            VStack(spacing: 30) {
                ProgressView(value: 9, total: 15)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Current weight")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    Text("Weight is used to calculate your calories")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                Picker("Weight", selection: $selectedWeight) {
                    ForEach(Array(stride(from: 30.0, through: 200.0, by: 0.5)), id: \.self) { value in
                        Text(String(format: "%.1f kg", value)).tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 120)
                Spacer()
                Button(action: {
                    onboardingData.weight = selectedWeight
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
        .onAppear {
            selectedWeight = onboardingData.weight > 0 ? onboardingData.weight : 75.0
        }
    }
} 