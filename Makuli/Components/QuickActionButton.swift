//
//  QuickActionButton.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct QuickActionButton: View {
    
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(AppColors.primaryOrange.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.primaryOrange)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textCharcoal)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.bgCream)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 16) {
        QuickActionButton(
            icon: "list.bullet",
            title: "Grocery List",
            action: {}
        )
        
        QuickActionButton(
            icon: "magnifyingglass",
            title: "Explore Recipes",
            action: {}
        )
    }
    .padding()
}
