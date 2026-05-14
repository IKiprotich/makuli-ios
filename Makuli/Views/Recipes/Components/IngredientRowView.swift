//
//  IngredientRowView.swift
//  Makuli
//
//  Created by Ian on 2025-06-22.
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
                    .foregroundColor(ingredient.isCompleted ? AppColors.successGreen : AppColors.text.opacity(0.3))
                    .font(.title3)
            }
            .accessibilityLabel(ingredient.isCompleted ? "mark as incomplete" : "mark as complete")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.formattedQuantity)
                    .font(AppFonts.body())
                    .foregroundColor(AppColors.text)
                    .strikethrough(ingredient.isCompleted)
                
                Text(ingredient.name)
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.text.opacity(0.3))
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
}
