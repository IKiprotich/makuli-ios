//
//  HomeViewModel.swift
//  Makuli
//
//  Created by Ian   on 30/06/2025.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var navigateToWeekDetail = false
    
    // Sample data from centralized MockData
    let sampleMeals = MockData.sampleMeals
    let sampleMetrics = MockData.sampleMetrics
    
    // Navigation actions
    func handleGroceryListTap() {
        navigateToWeekDetail = true
    }
    
    func handleExploreRecipesTap(selectedTab: Binding<Int>) {
        selectedTab.wrappedValue = 2
    }
    
    func handleProfileTap(selectedTab: Binding<Int>) {
        selectedTab.wrappedValue = 3
    }
    
    func handleSettingsTap(selectedTab: Binding<Int>) {
        selectedTab.wrappedValue = 3
    }
} 