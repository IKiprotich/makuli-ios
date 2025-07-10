//
//  AgeInputView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import SwiftUI

struct AgeInputView: View {
    
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    @State private var ageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    
    var body: some View {
        ZStack {
            AppColors.bgCream
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                //progress indicator
                ProgressView(value: 2, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("How old are you?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us personalize your meal plans")
                        .font(.body)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                
                //age input
                VStack(spacing: 15) {
                    TextField("Enter your age", text: $ageText)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.center)
                        .focused($isTextFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isTextFieldFocused = false
                                }
                                .foregroundColor(AppColors.primaryOrange)
                            }
                        }
                        .onChange(of: ageText) {
                            if let age = Int(ageText) {
                                onboardingData.age = age
                            }
                        }
                }
                
                
                Spacer()
                
                
                //continue button
                Button(action: {
                    isTextFieldFocused = false // Dismiss keyboard
                    if onboardingData.age > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 2
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            onboardingData.age > 0
                                ? AppColors.primaryOrange
                                : Color.gray.opacity(0.5)
                        )
                        .cornerRadius(12)
                }
                .disabled(onboardingData.age <= 0)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                
            }
        }
        .onTapGesture {
            isTextFieldFocused = false // Dismiss keyboard when tapping outside
        }
        .onAppear {
            if onboardingData.age > 0 {
                ageText = String(onboardingData.age)
            }
        }
    }
}

#Preview {
    AgeInputView(onboardingData: OnboardingData(), currentPage: .constant(1))
}
