//
//  MealCardView.swift
//  Makuli
//
//  Created by Ian on 2025-06-19.
//

import SwiftUI

struct MealCardView: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 12){
            VStack(alignment: .leading, spacing: 4){
                
                Text(meal.category.rawValue.capitalized)
                    .font(AppFonts.caption())
                    .foregroundColor(.secondary)
                
                Text(meal.name)
                    .font(AppFonts.headline())
                    .foregroundColor(.primary)
                
                Text("\(meal.cookingTime) min * \(meal.difficulty.rawValue.capitalized)")
                    .font(AppFonts.caption())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
        }
        .padding(16)
        .background(AppColors.background)
        .cornerRadius(12)
    }
}

