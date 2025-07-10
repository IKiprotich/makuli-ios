//
//  MealCardView.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct MealCardView: View {
    let meal: MealPlan
    
    var body: some View {
        HStack(spacing: 12){
            //meal plan description
            VStack(alignment: .leading, spacing: 4){
                
                Text(meal.mealType.rawValue)
                    .font(AppFonts.caption())
                    .foregroundColor(.secondary)
                
                Text(meal.name)
                    .font(AppFonts.headline())
                    .foregroundColor(.primary)
                
                Text("\(meal.duration) min * \(meal.difficulty.rawValue)")
                    .font(AppFonts.caption())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            //image of the mealplan(placeholder for now)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 60)
                .overlay(
                    Image(systemName: meal.imageName)
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
        }
        .padding(16)
        .background(AppColors.bgCream)
        .cornerRadius(12)
    }
}

#Preview {
    MealCardView(meal: MealPlan(mealType: MealType(rawValue: "breakfast")!, name: "Avocado Toast with Eggs", duration: 10, difficulty: Difficulty(rawValue: "easy")!, imageName: "cup.and.saucer", backgroundColor: "orange"))
}
