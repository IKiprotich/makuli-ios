//
//  PreviewContent.swift
//  Makuli
//
//  Created by Ian on 2025-06-13.
//

#if DEBUG
import Foundation

enum Preview {

    // MARK: - Single-item shorthands

    static var recipe: Recipe           { MockRecipes.grilledSalmon }
    static var breakfastRecipe: Recipe  { MockRecipes.avocadoToast }
    static var lunchRecipe: Recipe      { MockRecipes.quinoaBowl }
    static var dinnerRecipe: Recipe     { MockRecipes.chickenTikkaMasala }
    static var snackRecipe: Recipe      { MockRecipes.hummusPlatter }

    static var plan: Plan               { MockPlans.currentWeekPlan }
    static var completedPlan: Plan      { MockPlans.lastWeekPlan }

    static var planRecipe: PlanRecipe   { MockPlans.currentWeekRecipes[2] }
    static var completedMeal: PlanRecipe { MockPlans.currentWeekRecipes[0] }

    // MARK: - List shorthands

    static var recipes: [Recipe]        { MockRecipes.all }
    static var featuredRecipes: [Recipe] { MockRecipes.featured }
    static var breakfasts: [Recipe]     { MockRecipes.breakfasts }
    static var lunches: [Recipe]        { MockRecipes.lunches }
    static var dinners: [Recipe]        { MockRecipes.dinners }

    static var todaysMeals: [PlanRecipe]    { MockPlans.todaysMeals }
    static var upcomingMeals: [PlanRecipe]  { MockPlans.upcomingMeals }
    static var allPlans: [Plan]             { MockPlans.allPlans }

    // MARK: - ProgressMetrics

    static var progressMetrics: [ProgressMetric] {[
        ProgressMetric(title: "This Week",   value: "8/21",  change: "+8",   isPositive: true),
        ProgressMetric(title: "Today",       value: "2/3",   change: "67%",  isPositive: true),
        ProgressMetric(title: "Completion",  value: "38%",   change: "+5%",  isPositive: true),
        ProgressMetric(title: "Cost Saved",  value: "£14",   change: "vs avg", isPositive: true),
    ]}

    // MARK: - PlanWithRecipes helper

    static var planWithRecipes: (plan: Plan, recipes: [PlanRecipe]) {
        (plan: MockPlans.currentWeekPlan, recipes: MockPlans.currentWeekRecipes)
    }
}
#endif
