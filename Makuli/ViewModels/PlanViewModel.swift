//
//  PlanViewModel.swift
//  Makuli
//
//  Created by on 2025-07-03.
//
//  Handles fetching and managing meal plan data from Supabase.
//
import Foundation
import Supabase

@MainActor
class PlanViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var selectedWeek: WeekPlan?

    // Computed property: map Supabase plans to WeekPlan for UI
    var weekPlans: [WeekPlan] {
        let mapped = plans.compactMap { plan in
            // Parse week_start and created_at as Date
            let dateFormatter = ISO8601DateFormatter()
            let weekStartDate = plan.week_start.flatMap { dateFormatter.date(from: $0) } ?? Date()
            let endDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
            // Use plan.title as planName, fill in mock/defaults for missing fields
            return WeekPlan(
                weekNumber: Calendar.current.component(.weekOfYear, from: weekStartDate),
                startDate: weekStartDate,
                endDate: endDate,
                totalCost: 1500, // Placeholder, Supabase Plan does not have cost
                mealsCompleted: 3, // Placeholder
                totalMeals: 7, // Placeholder
                planName: plan.title,
                featuredImageName: "meal_placeholder", // Placeholder
                isActive: false, // Placeholder, could use logic if needed
                meals: [] // Placeholder, Supabase Plan does not have meals
            )
        }
        // If no plans from Supabase, return a default mock plan
        return mapped.isEmpty ? WeekPlan.mockData : mapped
    }

    // Computed property: the first active plan (or most recent)
    var activePlan: WeekPlan? {
        // Example: just return the first for now
        weekPlans.first
    }

    // Computed property: all but the active plan, sorted by weekNumber descending
    var pastPlans: [WeekPlan] {
        guard let active = activePlan else { return weekPlans }
        return weekPlans.filter { $0.id != active.id }.sorted { $0.weekNumber > $1.weekNumber }
    }

    // Add new plan (stub)
    func addNewPlan() {
        print("Add new plan tapped (not implemented)")
    }

    // Fetch from Supabase
    func fetchPlans(for userId: String) async {
        do {
            let response = try await SupabaseManager.shared.client
                .database
                .from("plans")
                .select("*")
                .eq("user_id", value: userId)
                .execute()
            let plans = try JSONDecoder().decode([Plan].self, from: response.data)
            self.plans = plans
            // Set selectedWeek to the first plan if not already set
            if selectedWeek == nil, let first = weekPlans.first {
                selectedWeek = first
            }
        } catch {
            print("Failed to fetch plans: \(error.localizedDescription)")
            // On error, also fall back to mock data
            self.plans = []
            if selectedWeek == nil, let first = weekPlans.first {
                selectedWeek = first
            }
        }
    }
} 