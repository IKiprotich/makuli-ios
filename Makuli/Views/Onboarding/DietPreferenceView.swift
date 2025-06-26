import SwiftUI

struct DietPreferenceView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let dietOptions = [
        ("No restrictions", "leaf.fill"),
        ("Vegetarian", "carrot.fill"),
        ("Vegan", "leaf.circle.fill"),
        ("Keto", "flame.fill"),
        ("Paleo", "mountain.2.fill"),
        ("Mediterranean", "fish.fill"),
        ("Gluten-free", "xmark.circle.fill"),
        ("Dairy-free", "drop.fill")
    ]
    
    var body: some View {
        ZStack {
            AppColors.bgCream.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress bar
                ProgressView(value: 6, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                // Title and subtitle
                VStack(spacing: 12) {
                    Text("Any dietary preferences?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("Select all that apply (optional)")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Diet selection grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(dietOptions, id: \.0) { option in
                            let isSelected = onboardingData.dietPreferences.contains(option.0)
                            
                            Button(action: {
                                if isSelected {
                                    onboardingData.dietPreferences.removeAll { $0 == option.0 }
                                } else {
                                    onboardingData.dietPreferences.append(option.0)
                                }
                            }) {
                                VStack(spacing: 10) {
                                    Image(systemName: option.1)
                                        .font(.title2)
                                        .foregroundColor(isSelected ? .white : AppColors.successGreen)
                                    
                                    Text(option.0)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(isSelected ? .white : AppColors.textCharcoal)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .background(
                                    isSelected
                                    ? AppColors.successGreen
                                    : Color.white.opacity(0.95)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isSelected
                                            ? Color.clear
                                            : AppColors.textCharcoal.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 36)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = 6
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
    }
}

#Preview {
    DietPreferenceView(
        onboardingData: OnboardingData(),
        currentPage: .constant(5)
    )
}
