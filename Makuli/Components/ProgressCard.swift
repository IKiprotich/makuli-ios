//
//  ProgressCard.swift
//  Makuli
//
//  Created by Ian on 2025-06-19.
//

import SwiftUI

struct ProgressCard: View {
    
    let metric: ProgressMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(metric.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Circle()
                    .fill(metric.isPositive ? AppColors.successGreen : AppColors.warnRed)
                    .frame(width: 8, height: 8)
            }
            
            Text(metric.value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.text)
            
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
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ProgressCard(metric: ProgressMetric(
        title: "This Week",
        value: "12/15",
        change: "+3",
        isPositive: true
    ))
    .padding()
}
