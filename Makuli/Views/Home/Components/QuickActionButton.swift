//
//  QuickActionButton.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct QuickActionButton: View {
    
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            
            HStack(spacing: 8){
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(AppColors.textCharcoal)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.bgCream)
            .cornerRadius(12)
            
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    //QuickActionButton()
}
