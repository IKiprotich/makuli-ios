//
//  CircularProgressView.swift
//  Makuli
//
//  Created by Ian   on 21/06/2025.
//

import SwiftUI

struct CircularProgressView: View {
    
    let progress: Double
    private let lineWidth: CGFloat = 6
    
    var body: some View {
        ZStack {
            //background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)
            
            //progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.successGreen,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
            
            //progress text
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
