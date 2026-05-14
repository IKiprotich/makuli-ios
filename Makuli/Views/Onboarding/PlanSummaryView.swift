//
//  PlanSummaryView.swift
//  Makuli
//
//  Created by Ian on 2025-07-23.
//

import SwiftUI

struct PlanSummaryView: View {
    @ObservedObject var onboardingData: OnboardingData
    @ObservedObject var onboardingViewModel: OnboardingViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var currentPage: Int
    let totalPages: Int

    var body: some View {
        ZStack {
            AppColors.background
            VStack(spacing: 30) {
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)

                VStack(spacing: 20) {
                    Text("Your plan is ready 🎉")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.text)
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
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)

                if let error = onboardingViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                Button(action: {
                    Task {
                        await onboardingViewModel.completeOnboarding(
                            authViewModel: authViewModel,
                            onboardingData: onboardingData
                        )
                    }
                }) {
                    if onboardingViewModel.isCompleting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Finish")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(AppColors.primaryOrange)
                .cornerRadius(12)
                .disabled(onboardingViewModel.isCompleting)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
    }
} 