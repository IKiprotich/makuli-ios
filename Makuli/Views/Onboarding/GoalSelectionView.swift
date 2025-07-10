//
//  GoalSelectionView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import SwiftUI

struct GoalSelectionView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let goalOptions = [
        ("Lose Weight", "Scale down and feel great", "minus.circle.fill"),
        ("Gain Weight", "Build mass and strength", "plus.circle.fill"),
        ("Maintain Weight", "Stay healthy and balanced", "equal.circle.fill"),
        ("Build Muscle", "Gain lean muscle mass", "figure.strengthtraining.traditional"),
        ("Improve Health", "Better nutrition overall", "heart.circle.fill")
    ]
    
    var body: some View {
        ZStack {
            AppColors.bgCream
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // progress indicator
                ProgressView(value: 4, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                VStack(spacing: 20) {
                    Text("What's your main goal?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose your primary health objective")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Goal selection
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(goalOptions, id: \.0) { option in
                            Button(action: {
                                onboardingData.goal = option.0
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: option.2)
                                        .font(.title2)
                                        .foregroundColor(
                                            onboardingData.goal == option.0
                                                ? .white
                                                : AppColors.primaryOrange
                                        )
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.0)
                                            .font(.headline)
                                            .foregroundColor(
                                                onboardingData.goal == option.0
                                                    ? .white
                                                : AppColors.textCharcoal
                                            )
                                        
                                        Text(option.1)
                                            .font(.caption)
                                            .foregroundColor(
                                                onboardingData.goal == option.0
                                                    ? .white.opacity(0.8)
                                                : AppColors.textCharcoal.opacity(0.6)
                                            )
                                    }
                                    
                                    Spacer()
                                    
                                    if onboardingData.goal == option.0 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(
                                    onboardingData.goal == option.0
                                        ? AppColors.primaryOrange
                                        : Color.white
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            onboardingData.goal == option.0
                                                ? Color.clear
                                                : Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    if !onboardingData.goal.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 4
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            !onboardingData.goal.isEmpty
                            ? AppColors.primaryOrange
                                : Color.gray.opacity(0.5)
                        )
                        .cornerRadius(12)
                }
                .disabled(onboardingData.goal.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    GoalSelectionView(
        onboardingData: OnboardingData(),
        currentPage: .constant(3)
    )
}
