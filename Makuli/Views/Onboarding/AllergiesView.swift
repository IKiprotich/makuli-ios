import SwiftUI

struct AllergiesView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let allergyOptions = [
        "Dairy", "Egg", "Fish", "Flax", "Gluten", "Meat", "Peanuts", "Sesame", "Shellfish", "Soya", "Tree nuts", "Celery", "Lupin", "Mustard", "Sulfites"
    ]
    
    var body: some View {
        ZStack {
            AppColors.bgCream.ignoresSafeArea()
            VStack(spacing: 30) {
                ProgressView(value: 6, total: 15)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Allergies")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    Text("Any allergies?")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(allergyOptions, id: \.self) { allergy in
                            let isSelected = onboardingData.allergies.contains(allergy)
                            Button(action: {
                                if isSelected {
                                    onboardingData.allergies.removeAll { $0 == allergy }
                                } else {
                                    onboardingData.allergies.append(allergy)
                                }
                            }) {
                                Text(allergy)
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