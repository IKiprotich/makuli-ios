//
//  SubstitutionSectionView.swift
//  Makuli
//
//  Created by Ian   on 22/06/2025.
//

import SwiftUI

struct SubstitutionSectionView: View {
    
    let substitutions: [String]
    @State private var isExpanded = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Button (action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }){
                HStack {
                    Text("local Swaps")
                        .font(AppFonts.headline())
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppColors.primaryOrange)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
            }
            .accessibilityLabel("Local ingredient swaps")
            .accessibilityHint("Tap to \(isExpanded ? "collapse" : "expand")")
           
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(substitutions.indices, id: \.self){ index in
                        HStack(alignment: .top, spacing: 8) {
                            
                            Text("•")
                                .foregroundColor(AppColors.successGreen)
                                .font(AppFonts.body())
                            
                            Text(substitutions[index])
                                .font(AppFonts.body())
                                .foregroundColor(AppColors.textCharcoal.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                            
                        }
                        
                    }
                    
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity))
                    
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.bgCream.opacity(0.7))
        )
    }
}

#Preview {
    //SubstitutionSectionView()
}
