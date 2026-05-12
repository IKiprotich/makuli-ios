//
//  StepCardView.swift
//  Makuli
//
//  Created by Ian   on 22/06/2025.
//

import SwiftUI

struct StepCardView: View {
    
    let stepNumber: Int
    let instruction: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            Text("\(stepNumber)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryOrange)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(AppColors.background)
                        .overlay(
                            Circle()
                                .stroke(AppColors.primaryOrange, lineWidth: 2)
                        )
                )
            
            Text(instruction)
                .font(AppFonts.body())
                .foregroundColor(AppColors.text)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.background.opacity(0.5))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(stepNumber): \(instruction)")
    }
}

#Preview {
   // StepCardView()
}
