//
//  ProgressTrackerSection.swift
//  Makuli
//
//  Created by Ian on 2025-06-19.
//

import SwiftUI

struct ProgressTrackerSection: View {
    
    let metrics : [ProgressMetric]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress Tracker")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    
                    Text("Track your weekly achievements")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                if metrics.count >= 2 {
                    HStack(spacing: 16) {
                        ProgressCard(metric: metrics[0])
                        ProgressCard(metric: metrics[1])
                    }
                }
                
                if metrics.count >= 3 {
                    ProgressCard(metric: metrics[2])
                }
                
                if metrics.count >= 4 {
                    ProgressCard(metric: metrics[3])
                }
            }
            
        }
    }
}

#Preview {
    ProgressTrackerSection(metrics: [
        ProgressMetric(title: "This Week", value: "12/15", change: "+3", isPositive: true),
        ProgressMetric(title: "Today", value: "3/4", change: "75%", isPositive: true),
        ProgressMetric(title: "Progress", value: "80%", change: "Great!", isPositive: true),
        ProgressMetric(title: "Groceries", value: "15/20", change: "Ready", isPositive: true)
    ])
    .padding()
}
