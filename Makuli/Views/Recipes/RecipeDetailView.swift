//
//  RecipeDetailView.swift
//  Makuli
//
//  Created by Ian on 2025-06-22.
//

import SwiftUI

struct RecipeDetailView: View {
    
    let recipe: Recipe
    @State private var ingredients: [Ingredient]
    @Environment(\.dismiss) private var dismiss
    
    init(recipe: Recipe) {
        self.recipe = recipe
        let convertedIngredients = recipe.ingredients.map { ingredientString in
            Ingredient(
                id: UUID().uuidString,
                recipeId: recipe.id,
                name: ingredientString,
                quantity: 1.0,
                unit: "piece",
                category: "Other",
                preparation: nil,
                notes: nil,
                isOptional: false,
                isGarnish: false,
                isCompleted: false,
                nutrition: nil,
                allergens: [],
                substitutions: [],
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        self._ingredients = State(initialValue: convertedIngredients)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                
                ingredientsSection
                
                if let substitutions = recipe.substitutions, !substitutions.isEmpty {
                    SubstitutionSectionView(substitutions: substitutions)
                        .padding(.horizontal)
                }
                
                stepsSection
                
                
                Spacer(minLength: 100)
            }
            .padding(.top)
            
        }
        .overlay(alignment: .bottom) {
            ctaSection
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
    }
}

extension RecipeDetailView {
    
    // MARK: Header section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🍽️")
                    .font(.system(size: 60))
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(AppColors.background)
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(AppFonts.title2())
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                    HStack(spacing: 12) {
                        badgeView(text: recipe.cookTime ?? "30 mins", icon: "clock")
                        badgeView(text: "Serves \(recipe.servings?.description ?? "4")", icon: "person.2")
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    
    private func badgeView(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            
            Image(systemName: icon)
                .font(.caption)
            
            Text(text)
                .font(AppFonts.caption())
        }
        .foregroundColor(AppColors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.successGreen.opacity(0.1))
        )
    }
    
    
    // MARK: Ingredients section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingredients")
                .font(AppFonts.headline())
                .foregroundColor(AppColors.text)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(ingredients.indices, id: \.self) { index in
                    IngredientRowView(ingredient: ingredients[index]) { updatedIngredient in
                        ingredients[index] = updatedIngredient
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.background)
            )
            .padding(.horizontal)
            
            
        }
    }
    
    
    // MARK: Steps section
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Steps")
                .font(AppFonts.headline())
                .foregroundColor(AppColors.text)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(recipe.steps.indices, id: \.self) { index in
                  StepCardView(
                    stepNumber: index + 1,
                    instruction: recipe.steps[index])
                    
                }
            }
        }
        .padding(.horizontal)
    }
    
    
    private var ctaSection: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white.opacity(0.9), Color.white],
                startPoint: .top,
                endPoint: .bottom)
            .frame(height: 20)
            
            
            HStack {
                Button(action: addToPlan) {
                    Text("Add to Plan")
                        .font(AppFonts.headline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(AppColors.primaryOrange)
                        .cornerRadius(20)
                }
                .primaryButtonStyle()
                .accessibilityLabel("Add recipe to meal plan")
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color.white)
            
        }
    }
    
    private func addToPlan(){
        Logger.debug("Adding recipe to plan")
    }
    
    
    
    
    
}

#if DEBUG
#Preview("Salmon") {
    RecipeDetailView(recipe: Preview.recipe)
}

#Preview("Tikka Masala") {
    RecipeDetailView(recipe: Preview.dinnerRecipe)
}

#Preview("Overnight Oats") {
    RecipeDetailView(recipe: Preview.breakfastRecipe)
}
#endif
