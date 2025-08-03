//
//  ProgressCard.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct ProgressCard: View {
    
    let metric: UIProgressMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(metric.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(metric.isPositive ? AppColors.successGreen : AppColors.warnRed)
                    .frame(width: 8, height: 8)
            }
            
            Text(metric.value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textCharcoal)
            
            if !metric.change.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: metric.isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(metric.isPositive ? AppColors.successGreen : AppColors.warnRed)
                    
                    Text(metric.change)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(metric.isPositive ? AppColors.successGreen : AppColors.warnRed)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.bgCream)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ProgressCard(metric: UIProgressMetrics(
        title: "This Week",
        value: "12/15",
        change: "+3",
        isPositive: true
    ))
    .padding()
}
