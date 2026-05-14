//
//  HeightInputView.swift
//  Makuli
//
//  Created by Ian on 2025-07-23.
//

import SwiftUI

struct HeightInputView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    @State private var selectedHeight: Double = 170.0
    var body: some View {
        ZStack {
            AppColors.background
            VStack(spacing: 30) {
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    Text("Current height")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                    Text("Height is used to calculate your calories")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                Picker("Height", selection: $selectedHeight) {
                    ForEach(Array(stride(from: 120.0, through: 220.0, by: 0.5)), id: \.self) { value in
                        Text(String(format: "%.1f cm", value)).tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 120)
                Spacer()
                Button(action: {
                    onboardingData.height = selectedHeight
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
        .ignoresSafeArea()
        .onAppear {
            selectedHeight = onboardingData.height > 0 ? onboardingData.height : 170.0
        }
    }
} 