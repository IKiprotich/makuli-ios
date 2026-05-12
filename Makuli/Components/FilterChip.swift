//
//  FilterChip.swift
//  Makuli
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : AppColors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? AnyShapeStyle(AppColors.primaryOrange) : AnyShapeStyle(AppColors.card))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                        )
                )
                .shadow(
                    color: isSelected ? AppColors.primaryOrange.opacity(0.25) : Color.clear,
                    radius: 6, x: 0, y: 3
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel("Filter by \(title)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack(spacing: 10) {
        FilterChip(title: "All",     isSelected: true,  action: {})
        FilterChip(title: "Quick",   isSelected: false, action: {})
        FilterChip(title: "Healthy", isSelected: false, action: {})
    }
    .padding()
    .background(AppColors.background)
}
