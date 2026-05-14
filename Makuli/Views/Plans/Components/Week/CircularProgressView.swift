//
//  CircularProgressView.swift
//  Makuli
//
//  Created by Ian on 2025-06-21.
//

import SwiftUI

struct CircularProgressView: View {
    
    let progress: Double
    private let lineWidth: CGFloat = 6
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.successGreen,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
            
            Text("\(Int(progress * 100)) %")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.text)
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.2)
}
