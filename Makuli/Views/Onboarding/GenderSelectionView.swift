//
//  GenderSelectionView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let genderOptions = ["Male", "Female", "Non-binary", "Prefer not to say"]
    
    var body: some View {
        ZStack {
            Color(hex: "#F9F7F4")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // progress indicator
                ProgressView(value: 3, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("What's your gender?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us provide better nutritional recommendations")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // gender selection
                VStack(spacing: 15) {
                    ForEach(genderOptions, id: \.self) { option in
                        Button(action: {
                            onboardingData.gender = option
                        }) {
                            HStack {
                                Text(option)
                                    .font(.headline)
                                    .foregroundColor(
                                        onboardingData.gender == option
                                            ? .white
                                        : AppColors.textCharcoal
                                    )
                                
                                Spacer()
                                
                                if onboardingData.gender == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                onboardingData.gender == option
                                ? AppColors.primaryOrange
                                    : Color.white
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        onboardingData.gender == option
                                            ? Color.clear
                                            : Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // continue button
                Button(action: {
                    if !onboardingData.gender.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 3
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            !onboardingData.gender.isEmpty
                            ? AppColors.primaryOrange
                                : Color.gray.opacity(0.5)
                        )
                        .cornerRadius(12)
                }
                .disabled(onboardingData.gender.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    GenderSelectionView(
        onboardingData: OnboardingData(),
        currentPage: .constant(2)
    )
}
