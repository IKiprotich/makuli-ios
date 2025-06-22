//
//  IngredientRowView.swift
//  Makuli
//
//  Created by Ian   on 22/06/2025.
//

import SwiftUI

struct IngredientRowView: View {
    
    @State private var ingredient: Ingredient
    let onToggle: (Ingredient) -> Void
    
    init(ingredient: Ingredient, onToggle: @escaping (Ingredient) -> Void) {
        self.ingredient = ingredient
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            
            Button {
                toggleCompletion()
            } label: {
                Image(systemName: ingredient.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(ingredient.isCompleted ? AppColors.successGreen : AppColors.textCharcoal.opacity(0.3))
                    .font(.title3)
            }
            .accessibilityLabel(ingredient.isCompleted ? "mark as incomplete" : "mark as complete")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.quantity)
                    .font(AppFonts.body())
                    .foregroundColor(AppColors.textCharcoal)
                    .strikethrough(ingredient.isCompleted)
                
                Text(ingredient.name)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textCharcoal.opacity(0.3))
                    .strikethrough(ingredient.isCompleted)
            }
            
            Spacer()
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleCompletion()
        }
        .animation(.easeInOut(duration: 0.2), value: ingredient.isCompleted)
    }
    
    
    private func toggleCompletion() {
        ingredient.isCompleted.toggle()
        onToggle(ingredient)
    }
}





#Preview {
   // IngredientRowView()
}
