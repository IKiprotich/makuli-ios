//
//  TemplateSelectionView.swift
//  Makuli
//
//  Created by Ian on 2025-01-08.
//

import SwiftUI

struct TemplateSelectionView: View {
    @StateObject private var planViewModel = PlanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: TemplateCategory? = nil
    @State private var showingSeedAlert = false
    @State private var seedingTemplates = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if planViewModel.templates.isEmpty && !planViewModel.isLoadingTemplates {
                        emptyStateSection
                    } else {
                        categoryFiltersSection
                        templatesGridSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
            .task {
                await planViewModel.fetchTemplates()
            }
            .refreshable {
                await planViewModel.fetchTemplates()
            }
            .alert("Seed Sample Templates", isPresented: $showingSeedAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Seed Templates") {
                    Task {
                        seedingTemplates = true
                        Logger.info("Template seeding not yet implemented")
                        seedingTemplates = false
                        await planViewModel.fetchTemplates()
                    }
                }
            } message: {
                Text("This will add sample meal plan templates to the database. Continue?")
            }
        }
    }
}

extension TemplateSelectionView {
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pick a meal plan template to get started quickly")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            if let errorMessage = planViewModel.templateErrorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.below.ecg")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primaryOrange)
            
            Text("No Templates Available")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("It looks like the template database needs to be set up. Would you like to add some sample templates to get started?")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button {
                showingSeedAlert = true
            } label: {
                HStack {
                    if seedingTemplates {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "plus.circle.fill")
                    }
                    Text(seedingTemplates ? "Setting up..." : "Setup Templates")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppColors.primaryOrange)
                .cornerRadius(25)
            }
            .disabled(seedingTemplates)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var categoryFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button {
                    selectedCategory = nil
                } label: {
                    HStack {
                        Text("All")
                        Text("(\(planViewModel.templates.count))")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .fontWeight(selectedCategory == nil ? .semibold : .medium)
                    .foregroundColor(selectedCategory == nil ? .white : AppColors.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedCategory == nil ? AppColors.primaryOrange : Color(.systemGray6))
                    .cornerRadius(20)
                }
                
                ForEach(planViewModel.templateCategories, id: \.self) { category in
                    let categoryCount = planViewModel.templates(for: category).count
                    
                    if categoryCount > 0 {
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack {
                                Text(category.icon)
                                Text(category.rawValue)
                                Text("(\(categoryCount))")
                                    .font(.caption)
                            }
                            .font(.subheadline)
                            .fontWeight(selectedCategory == category ? .semibold : .medium)
                            .foregroundColor(selectedCategory == category ? .white : AppColors.text)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? AppColors.primaryOrange : Color(.systemGray6))
                            .cornerRadius(20)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var templatesGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(filteredTemplates, id: \.id) { template in
                TemplateSelectionCard(
                    template: template,
                    onSelect: {
                        await selectTemplate(template)
                    }
                )
            }
        }
        .overlay {
            if planViewModel.isLoadingTemplates {
                ProgressView("Loading templates...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.8))
            }
        }
    }
    
    private var filteredTemplates: [MealPlanTemplate] {
        if let selectedCategory = selectedCategory {
            return planViewModel.templates(for: selectedCategory)
        } else {
            return planViewModel.templates
        }
    }
    
    // MARK: - Actions
    
    private func selectTemplate(_ template: MealPlanTemplate) async {
        guard let user = authViewModel.user else {
            Logger.error("No authenticated user found")
            return
        }
        
        let weekStart = Calendar.current.startOfDay(for: Date())
        
        let success = await planViewModel.createPlanFromTemplate(
            templateId: template.id,
            for: user.id,
            weekStart: weekStart,
            userProfile: UserProfile(
                id: user.id,
                userId: user.id,
                name: user.name,
                email: user.email,
                age: user.age,
                gender: user.gender,
                goal: user.goal,
                diet: user.diet,
                budget: user.budget,
                isPremium: user.isPremium,
                isOnboardingCompleted: user.isOnboardingCompleted,
                subscriptionType: "free",
                subscriptionRenewal: nil,
                plansCreatedThisMonth: 0,
                spoonacularGenerationsThisMonth: 0,
                lastPlanReset: Date(),
                profileImageUrl: user.profileImageUrl,
                bio: nil,
                location: nil,
                preferredLanguage: "en",
                timezone: TimeZone.current.identifier,
                measurementSystem: "Metric",
                preferredCurrency: "USD",
                notificationPreferences: NotificationPreferences(
                    mealReminders: false,
                    groceryReminders: false,
                    achievementNotifications: false,
                    weeklyReports: false,
                    newRecipeNotifications: false,
                    preferredNotificationTime: "08:00",
                    pushNotificationsEnabled: false,
                    emailNotificationsEnabled: false
                ),
                privacySettings: PrivacySettings(
                    isProfilePublic: false,
                    mealPlansVisible: false,
                    progressSharingEnabled: false,
                    achievementsPublic: false,
                    locationSharingEnabled: false
                ),
                fitnessGoals: FitnessGoals(
                    targetWeight: nil,
                    targetCalories: nil,
                    targetProtein: nil,
                    targetCarbohydrates: nil,
                    targetFat: nil,
                    weeklyWorkoutMinutes: nil,
                    targetStepsPerDay: nil
                ),
                mealPlanningPreferences: MealPlanningPreferences(
                    mealsPerDay: 3,
                    preferredPrepTime: 30,
                    includeSnacks: false,
                    preferredCuisines: [],
                    rotateMeals: false,
                    includeLeftovers: false,
                    preferredComplexity: "Easy"
                ),
                dietaryPreferences: DietaryPreferences(
                    restrictions: [],
                    allergies: [],
                    favoriteIngredients: [],
                    dislikedIngredients: [],
                    avoidIngredients: [],
                    preferredCookingMethods: []
                ),
                cookingPreferences: CookingPreferences(
                    skillLevel: "Beginner",
                    preferredCookingTime: 30,
                    useAppliances: false,
                    preferredMethods: [],
                    usePreMadeIngredients: false,
                    batchCooking: false
                ),
                budgetPreferences: BudgetPreferences(
                    weeklyBudget: nil,
                    monthlyBudget: nil,
                    preferredMealPrice: nil,
                    prioritizeBudget: false,
                    includePremiumIngredients: false,
                    suggestAlternatives: false
                ),
                achievements: [],
                progressMetrics: [],
                spoonacularUsername: nil,
                spoonacularHash: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        
        if success {
            dismiss()
        }
    }
}

// MARK: - Template Card Component

struct TemplateSelectionCard: View {
    let template: MealPlanTemplate
    let onSelect: () async -> Void
    
    @State private var isCreating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(categoryIcon)
                    .font(.title2)
                
                Spacer()
                
                Text(template.cookingSkillLevel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(difficultyColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor.opacity(0.1))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(template.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(template.description ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Label {
                        Text("$\(Int(template.maxCostPerMeal ?? 0)) per meal")
                            .font(.caption)
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Label {
                        Text("\(template.durationDays) days")
                            .font(.caption)
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                }
                .foregroundColor(.secondary)
            }
            
            Button {
                Task {
                    isCreating = true
                    await onSelect()
                    isCreating = false
                }
            } label: {
                HStack {
                    if isCreating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "plus")
                    }
                    Text(isCreating ? "Creating..." : "Use Template")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AppColors.primaryOrange)
                .cornerRadius(8)
            }
            .disabled(isCreating)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var categoryIcon: String {
        if let category = TemplateCategory.allCases.first(where: { $0.rawValue == template.category }) {
            return category.icon
        }
        return "🍽️"
    }
    
    private var difficultyColor: Color {
        switch template.cookingSkillLevel.lowercased() {
        case "beginner":
            return .green
        case "intermediate":
            return .orange
        case "advanced":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Preview

#Preview {
    TemplateSelectionView()
        .environmentObject(AuthViewModel())
} 