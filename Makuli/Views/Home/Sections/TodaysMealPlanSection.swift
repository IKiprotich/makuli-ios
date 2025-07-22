//
//  TodaysMealPlanSection.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct TodaysMealPlanSection: View {
    
    let meals : [Meal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Meal Plan")
                    .font(AppFonts.title2())
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            ForEach(meals, id: \.id) { meal in
                MealCardView(meal: meal)
            }
            
        }
    }
}

#Preview {
    //TodaysMealPlanSection()
}
