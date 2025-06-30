//
//  FilterChip.swift
//  Makuli
//
//  Created by Ian   on 30/06/2025.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(.label))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? AppColors.primaryOrange : Color(.secondarySystemFill))
                )
        }
        .accessibilityLabel("Filter by \(title)")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to filter recipes")
    }
}

// MARK: - Preview
struct FilterChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            FilterChip(title: "All", isSelected: true, action: {})
            FilterChip(title: "Quick", isSelected: false, action: {})
        }
        .padding()
    }
} 