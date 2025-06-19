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
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text("Quick Access Actions")
                    .font(.title2)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 16){
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
   // QuickAccessSection()
}
