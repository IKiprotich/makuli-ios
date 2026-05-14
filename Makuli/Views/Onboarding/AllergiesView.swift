//
//  AllergiesView.swift
//  Makuli
//
//  Created by Ian on 2025-07-23.
//

import SwiftUI

struct AllergiesView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    @State private var selectedAllergies: [String] = []
    
    private let allergyOptions = [
        "Dairy", "Egg", "Fish", "Flax", "Gluten", "Meat", "Peanuts", "Sesame", "Shellfish", "Soya", "Tree nuts", "Celery", "Lupin", "Mustard", "Sulfites"
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
                    Text("Allergies")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                    Text("Any allergies?")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(allergyOptions, id: \.self) { allergy in
                            let isSelected = selectedAllergies.contains(allergy)
                            Button(action: {
                                if isSelected {
                                    selectedAllergies.removeAll { $0 == allergy }
                                } else {
                                    selectedAllergies.append(allergy)
                                }
                                DispatchQueue.main.async {
                                    onboardingData.allergies = selectedAllergies
                                }
                            }) {
                                Text(allergy)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : AppColors.text)
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
                    DispatchQueue.main.async {
                        onboardingData.allergies = selectedAllergies
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
        .ignoresSafeArea()
        .onAppear {
            selectedAllergies = onboardingData.allergies
        }
    }
} 