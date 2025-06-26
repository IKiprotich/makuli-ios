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
    
    
    var body: some View {
        ZStack {
            AppColors.bgCream
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                //progress indicator
                ProgressView(value: 2, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#F97316")))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("How old are you?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#1F2937"))
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us personalize your meal plans")
                        .font(.body)
                        .foregroundColor(Color(hex: "#1F2937").opacity(0.7))
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
                        .onChange(of: ageText) { newValue in
                            if let age = Int(newValue) {
                                onboardingData.age = age
                            }
                        }
                }
                
                
                Spacer()
                
                
                //continue button
                Button(action: {
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
                                ? Color(hex: "#F97316")
                                : Color.gray.opacity(0.5)
                        )
                        .cornerRadius(12)
                }
                .disabled(onboardingData.age <= 0)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                
            }
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
