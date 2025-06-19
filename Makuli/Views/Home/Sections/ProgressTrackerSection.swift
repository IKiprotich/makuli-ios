//
//  ProgressTrackerSection.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct ProgressTrackerSection: View {
    
    let metrics : [ProgressMetrics]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            
            HStack {
                Text("Progress Tracker")
                    .font(.title2)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if metrics.count >= 2 {
                    HStack(spacing: 12){
                        ProgressCard(metric: metrics[0])
                        ProgressCard(metric: metrics[1])
                    }
                }
                
                if metrics.count >= 3 {
                    ProgressCard(metric: metrics[2])
                }
            }
            
        }
    }
}

#Preview {
    //ProgressTrackerSection()
}
