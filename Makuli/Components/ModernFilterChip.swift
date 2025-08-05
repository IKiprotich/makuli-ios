//
//  ModernFilterChip.swift
//  Makuli
//
//  Created by ian on 2025-08-05.
//
//  Modern, vibrant filter chip component following Apple HIG.
//

import SwiftUI

struct ModernFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Emoji icon based on filter type
                Text(getEmojiForFilter(title))
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : AppColors.text)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            colors: [
                                AppColors.primaryOrange,
                                AppColors.primaryOrange.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.clear : AppColors.primaryOrange.opacity(0.2),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primaryOrange.opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel("Filter by \(title)")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to filter recipes")
    }
    
    // Helper function to get emoji for each filter type
    private func getEmojiForFilter(_ filter: String) -> String {
        switch filter.lowercased() {
        case "all":
            return "🍽️"
        case "quick":
            return "⚡"
        case "healthy":
            return "🥗"
        case "high-protein":
            return "💪"
        case "budget":
            return "💰"
        case "traditional":
            return "🏛️"
        case "vegetarian":
            return "🥬"
        case "vegan":
            return "🌱"
        case "gluten-free":
            return "🌾"
        case "dairy-free":
            return "🥛"
        default:
            return "🍳"
        }
    }
}

// MARK: - Preview
struct ModernFilterChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ModernFilterChip(title: "All", isSelected: true, action: {})
            ModernFilterChip(title: "Quick", isSelected: false, action: {})
            ModernFilterChip(title: "Healthy", isSelected: false, action: {})
            ModernFilterChip(title: "High-Protein", isSelected: false, action: {})
        }
        .padding()
        .background(AppColors.background)
    }
} 