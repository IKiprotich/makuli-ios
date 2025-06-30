//
//  PlansViewModel.swift
//  Makuli
//
//  Created by Ian   on 30/06/2025.
//

import Foundation

@MainActor
class PlansViewModel: ObservableObject {
    @Published var weekPlans = WeekPlan.mockData
    @Published var selectedWeek: WeekPlan?
    
    var activePlan: WeekPlan? {
        weekPlans.first { $0.isActive }
    }
    
    var pastPlans: [WeekPlan] {
        weekPlans.filter { !$0.isActive }.sorted { $0.weekNumber > $1.weekNumber }
    }
    
    init() {
        selectedWeek = weekPlans.first
    }
    
    // Actions
    func addNewPlan() {
        // TODO: Implement add plan functionality
        Logger.debug("Add new plan tapped")
    }
    
    func selectWeek(_ week: WeekPlan) {
        selectedWeek = week
    }
} 