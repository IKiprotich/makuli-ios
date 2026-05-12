import SwiftUI

struct CuisinePreferenceView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let cuisineOptions = [
        "American", "Mediterranean", "Mexican", "Asian", "Italian", "Chinese", "Indian", "Japanese", "Thai"
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 30) {
                ProgressView(value: 11, total: 15)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Cuisine")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                    Text("Any cuisines you like or dislike?")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(cuisineOptions, id: \.self) { cuisine in
                            HStack {
                                Text(cuisine)
                                    .font(.headline)
                                    .foregroundColor(AppColors.text)
                                Spacer()
                                Button(action: {
                                    if onboardingData.preferredCuisines.contains(cuisine) {
                                        onboardingData.preferredCuisines.removeAll { $0 == cuisine }
                                    } else {
                                        onboardingData.preferredCuisines.append(cuisine)
                                        onboardingData.dislikedCuisines.removeAll { $0 == cuisine }
                                    }
                                }) {
                                    Image(systemName: onboardingData.preferredCuisines.contains(cuisine) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .foregroundColor(onboardingData.preferredCuisines.contains(cuisine) ? AppColors.primaryOrange : .gray)
                                        .font(.title2)
                                }
                                Button(action: {
                                    if onboardingData.dislikedCuisines.contains(cuisine) {
                                        onboardingData.dislikedCuisines.removeAll { $0 == cuisine }
                                    } else {
                                        onboardingData.dislikedCuisines.append(cuisine)
                                        onboardingData.preferredCuisines.removeAll { $0 == cuisine }
                                    }
                                }) {
                                    Image(systemName: onboardingData.dislikedCuisines.contains(cuisine) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                        .foregroundColor(onboardingData.dislikedCuisines.contains(cuisine) ? AppColors.warnRed : .gray)
                                        .font(.title2)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(10)
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