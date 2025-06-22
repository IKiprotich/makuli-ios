//
//  MealRowView.swift
//  Makuli
//
//  Created by Ian   on 21/06/2025.
//

import SwiftUI

struct MealRowView: View {
    
    let meal: Meal
    let isExpanded: Bool
    let onExpansionToggle: (() -> Void)?
    let recipe: Recipe?
    
    // Initialize with optional closure and recipe
    init(meal: Meal, isExpanded: Bool, onExpansionToggle: (() -> Void)? = nil, recipe: Recipe? = nil) {
        self.meal = meal
        self.isExpanded = isExpanded
        self.onExpansionToggle = onExpansionToggle
        self.recipe = recipe
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing:0) {
            //main meal row
            HStack(spacing: 16) {
                //meal category icon
                Image(systemName: meal.category.icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(meal.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textCharcoal)
                    
                    
                    HStack(spacing: 8) {
                        
                        Text(meal.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(meal.cookingTime) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    // Handle expansion toggle when tapping the meal info area
                    onExpansionToggle?()
                }
                
                Spacer()
                
            //action buttons
                HStack(spacing: 12) {
                    if meal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.successGreen)
                            .font(.system(size: 20))
                    }
                    else {
                        Button {
                            //implement mark as completed functionality
                        } label: {
                            Image(systemName: "circle")
                                .foregroundColor(.secondary)
                                .font(.system(size: 20))
                        }

                    }
                    
                    //view recipes button - only show if recipe exists
                    if let recipe = recipe {
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            Text("View Recipe")
                                .font(.caption)
                                .foregroundColor(Color("PrimaryOrange"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color("WarmSand"))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            
            //expanded content
            if isExpanded {
                expandedContent
            }
        }
        .background(AppColors.warmsand)
    }
}


extension MealRowView {
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Divider()
                .padding(.horizontal, 20)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Difficulty")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(meal.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textCharcoal)
                }
                
                
                Spacer()
                
                
                Button("Add Ingredients"){
                    //implement the add recipe to the grocery list functionality
                }
                .font(.caption)
                .foregroundColor(AppColors.primaryOrange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppColors.primaryOrange, lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
    
    private var iconColor: Color {
        switch meal.category {
        case .breakfast: return .orange
        case .lunch: return .blue
        case .dinner: return .purple
        }
    }
    
}

#Preview {
    //MealRowView()
}
