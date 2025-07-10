//
//  WeekDetailView.swift
//  Makuli
//
//  Created by Ian   on 21/06/2025.
//

import SwiftUI

struct WeekDetailView: View {
    
    let plan: PlanWithRecipes
    @State private var dayPlans: [DayPlan] = []
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    
                    //main content
                    ScrollView {
                        VStack (spacing: 0) {
                            
                            //header section
                            headerSection
                            
                            //daycards
                            LazyVStack(spacing: 16){
                                ForEach(dayPlans) { dayPlan in
                                    DayCardView(dayPlan: dayPlan)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 100) //the space for the sticky button
                        }
                    }
                    
                    //sticky bottom button
                    // groceryListButton
                    //     .padding(.horizontal, 20)
                    //     .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                }
            }
            .navigationBarHidden(true)
            .background(
                AppColors.warmsand.opacity(0.3)
            )
            .onAppear {
                dayPlans = generateDayPlans(from: plan)
            }
            // Add the floating action button as a safe area inset
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    NavigationLink(destination: GroceryListView()) {
                        HStack {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("🛒 Generate Grocery List")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(AppColors.primaryOrange)
                        .cornerRadius(25)
                        .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    Spacer()
                }
                .padding(.bottom, 16)
                .background(AppColors.bgCream.opacity(0.9))
            }
//            .navigationDestination(for: Recipe.self) { recipe in
//                RecipeDetailView(recipe: recipe)
//            }
        }
    }
    
    func generateGroceryList() -> [GroceryItem] {
        var ingredientMap: [String: GroceryItem] = [:]
        for planRecipe in plan.recipes {
            // Note: This would need to be updated when we have actual Recipe objects linked to PlanRecipe
            if let ingredients = planRecipe.customIngredients {
                for ingredient in ingredients {
                    let key = ingredient.lowercased()
                    if ingredientMap[key] == nil {
                        ingredientMap[key] = GroceryItem(
                            id: UUID().uuidString,
                            name: ingredient,
                            quantity: "1", // Default quantity since we don't have detailed ingredient data
                            category: "Other", // Default category
                            emoji: "🥄" // Default emoji
                        )
                    }
                }
            }
        }
        return Array(ingredientMap.values).sorted { $0.name < $1.name }
    }
    
    func generateDayPlans(from plan: PlanWithRecipes) -> [DayPlan] {
        let calendar = Calendar.current
        var dayPlans: [DayPlan] = []
        
        // Create day plans for each day of the week
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: plan.plan.weekStart) else { continue }
            
            let dayName = date.dayOfWeek
            let dayNumber = "\(calendar.component(.day, from: date))"
            
            // Get meals for this specific day based on day of week
            let mealsForDay = plan.recipes.filter { planRecipe in
                return planRecipe.dayOfWeek == calendar.component(.weekday, from: date) - 1 // Sunday = 0
            }
            
            // If no meals scheduled for this day, create empty day
            let dayMeals = mealsForDay.isEmpty ? [] : mealsForDay
            let isCompleted = !dayMeals.isEmpty && dayMeals.allSatisfy { $0.isCompleted }
            
            let dayPlan = DayPlan(
                dayName: dayName,
                dayNumber: dayNumber,
                meals: [], // For now, empty meals array since DayPlan expects different meal structure
                isCompleted: isCompleted,
                date: date
            )
            
            dayPlans.append(dayPlan)
        }
        
        return dayPlans
    }
}


extension WeekDetailView {
    
    //header section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Navigation and title
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(AppColors.textCharcoal)
                }
                .accessibilityLabel("Go back")
                
                
                Spacer()
                
                
                Text(plan.plan.title + " Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textCharcoal)
                
                Spacer()
                
                
                Button (action:{
                    // implement more options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(AppColors.textCharcoal)
                }
                .accessibilityLabel("More options")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Budget and progress card
            budgetProgressCard
                .padding(.horizontal, 20)
        }
    }
    
    //budget progress card
    private var budgetProgressCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$\(Int((plan.plan.totalCost ?? 0.0) * 0.8).formatted())")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("/ $\(Int(plan.plan.totalCost ?? 0.0).formatted())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("\(plan.recipes.filter { $0.isCompleted }.count) of \(plan.recipes.count) Meals Completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // circular progress indicator
            CircularProgressView(progress: plan.plan.progress)
                .frame(width: 60, height: 60)
            
            Button("Add to Grocery List") {
                // implement the add to grocery list action
            }
            .font(.caption)
            .foregroundColor(AppColors.primaryOrange)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.warmsand)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    
    //grocery list button
    private var groceryListButton: some View {
        Button(action: {
            //implement the generate grocery list function
        }){
            HStack {
                Image(systemName: "cart.fill")
                Text("Finish Week")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("PrimaryOrange"))
            )
        }
        .accessibilityLabel("Generate grocery list for this week")
        
    }
    
}

#Preview {
    WeekDetailView(plan: Plan.mockWeeklyPlan())
}
