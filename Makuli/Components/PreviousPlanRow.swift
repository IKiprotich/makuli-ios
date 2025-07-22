//
//  PreviousPlanRow.swift
//  Makuli
//
//  Created by Ian   on 30/06/2025.
//

import SwiftUI

struct PreviousPlanRow: View {
    let plan: WeekPlan
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.weekTitle)
                    .font(.headline)
                    .foregroundColor(AppColors.textCharcoal)
                
                Text(plan.planName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Previous plan: \(plan.planName) from week \(plan.weekNumber)"))
        .accessibilityHint(Text("Tap to view details"))
    }
}

// MARK: - Preview
struct PreviousPlanRow_Previews: PreviewProvider {
    static var previews: some View {
        // Preview removed due to missing mockData
        Text("PreviousPlanRow Preview")
            .padding()
    }
} 