import SwiftUI

struct BudgetInputView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let budgetOptions = [
        ("$50 - $100", "Budget-friendly meals", "dollarsign.circle.fill"),
        ("$100 - $200", "Balanced nutrition", "dollarsign.circle.fill"),
        ("$200 - $300", "Premium ingredients", "dollarsign.circle.fill"),
        ("$300+", "Gourmet experience", "dollarsign.circle.fill")
    ]
    
    var body: some View {
        ZStack {
            AppColors.bgCream.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress bar
                ProgressView(value: 5, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    Text("What's your weekly food budget?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("We'll suggest meals that fit your budget")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Budget selection
                VStack(spacing: 15) {
                    ForEach(budgetOptions, id: \.0) { option in
                        let isSelected = onboardingData.budget == option.0
                        
                        Button(action: {
                            onboardingData.budget = option.0
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: option.2)
                                    .font(.title2)
                                    .foregroundColor(isSelected ? .white : AppColors.successGreen)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(option.0)
                                        .font(.headline)
                                        .foregroundColor(isSelected ? .white : AppColors.textCharcoal)
                                    
                                    Text(option.1)
                                        .font(.caption)
                                        .foregroundColor(isSelected
                                            ? .white.opacity(0.85)
                                            : AppColors.textCharcoal.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(isSelected ? AppColors.primaryOrange : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isSelected ? Color.clear : Color.gray.opacity(0.25),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    if !onboardingData.budget.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 5
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            onboardingData.budget.isEmpty
                            ? Color.gray.opacity(0.5)
                            : AppColors.primaryOrange
                        )
                        .cornerRadius(12)
                }
                .disabled(onboardingData.budget.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    BudgetInputView(
        onboardingData: OnboardingData(),
        currentPage: .constant(4)
    )
}
