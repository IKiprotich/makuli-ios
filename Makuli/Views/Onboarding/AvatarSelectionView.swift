import SwiftUI

struct AvatarSelectionView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    
    private let emojiOptions = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐸", "🐵", "🦉", "🐙"
    ]
    
    var body: some View {
        ZStack {
            AppColors.background
            VStack(spacing: 30) {
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Most important step…")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                    Text("Pick your avatar")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            let isSelected = onboardingData.avatarEmoji == emoji
                            Button(action: {
                                onboardingData.avatarEmoji = emoji
                            }) {
                                ZStack {
                                    Text(emoji)
                                        .font(.system(size: 40))
                                        .frame(width: 60, height: 60)
                                        .background(isSelected ? AppColors.primaryOrange : Color.white)
                                        .cornerRadius(30)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(isSelected ? AppColors.primaryOrange : Color.gray.opacity(0.3), lineWidth: 2)
                                        )
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(AppColors.primaryOrange))
                                            .offset(x: 18, y: -18)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                Spacer()
                Button(action: {
                    if !onboardingData.avatarEmoji.isEmpty {
                        currentPage += 1
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!onboardingData.avatarEmoji.isEmpty ? AppColors.primaryOrange : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                }
                .disabled(onboardingData.avatarEmoji.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
    }
} 