//
//  QuickAccessSection.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct QuickAccessSection: View {
    
    let onGroceryListTap: () -> Void
    let onExploreRecipeTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Access")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("Get things done faster")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textCharcoal.opacity(0.6))
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                QuickActionButton(icon: "list.bullet",
                                  title: "Grocery List",
                                  action: onGroceryListTap)
                
                QuickActionButton(icon: "magnifyingglass",
                                  title: "Explore Recipes",
                                  action: onExploreRecipeTap)
            }
            
        }
    }
}

#Preview {
    QuickAccessSection(
        onGroceryListTap: {},
        onExploreRecipeTap: {}
    )
    .padding()
}
