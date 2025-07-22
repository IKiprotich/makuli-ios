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
        VStack(alignment: .leading, spacing: 8){
            Text(metric.title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(metric.value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(metric.change)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(metric.isPositive ? .green : .red)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.bgCream)
        .cornerRadius(12)
    }
}

#Preview {
    //ProgressCard()
}
