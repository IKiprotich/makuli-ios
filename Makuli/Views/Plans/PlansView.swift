//
//  PlansView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct PlansView: View {
    @StateObject var viewModel = PlanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingMealPlanGeneration = false
    @State private var showingTemplateSelection = false
    @State private var showingDateSelection = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let errorMessage = viewModel.errorMessage {
                            // Error state
                            errorView(errorMessage)
                        } else if viewModel.plans.isEmpty {
                            // Empty state - first time user
                            emptyStateView
                        } else {
                            // User has existing plans
                            existingPlansView
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .task {
                if let user = authViewModel.user, !user.email.isEmpty {
                    await viewModel.fetchPlans(for: user.id)
                }
            }
            .sheet(isPresented: $showingMealPlanGeneration) {
                MealPlanGenerationView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showingTemplateSelection) {
                TemplateSelectionView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showingDateSelection) {
                MealPlanDateSelectionView()
                    .environmentObject(authViewModel)
            }
            .onChange(of: showingDateSelection) { isPresented in
                if !isPresented {
                    // Refresh plans when the sheet is dismissed
                    Task {
                        if let user = authViewModel.user, !user.email.isEmpty {
                            await viewModel.fetchPlans(for: user.id)
                        }
                    }
                }
            }
            .onChange(of: showingMealPlanGeneration) { isPresented in
                if !isPresented {
                    // Refresh plans when meal plan generation is dismissed
                    Task {
                        if let user = authViewModel.user, !user.email.isEmpty {
                            await viewModel.fetchPlans(for: user.id)
                        }
                    }
                }
            }
        }
    }
}

extension PlansView {
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.warnRed)
            
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)
            
            Text(message)
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    if let user = authViewModel.user, !user.email.isEmpty {
                        await viewModel.fetchPlans(for: user.id)
                    }
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primaryOrange)
            .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - Empty State View (First Time User)
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            // Hero Section with Emoji
            VStack(spacing: 24) {
                // Large Emoji Icon
                Text("🍽️")
                    .font(.system(size: 80))
                    .padding(.top, 40)
                
                // Main Title with Emoji
                VStack(spacing: 12) {
                    Text("Ready to Plan Your Meals?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Create personalized meal plans that fit your lifestyle and goals")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .padding(.horizontal, 24)
            }
            
            // Features Section with Modern Cards
            VStack(spacing: 16) {
                Text("What you'll get")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .padding(.top, 32)
                
                VStack(spacing: 12) {
                    featureCard(
                        emoji: "🌅",
                        title: "Daily Meals",
                        description: "Breakfast, lunch, and dinner planned for the week"
                    )
                    
                    featureCard(
                        emoji: "🎯",
                        title: "Personalized",
                        description: "Tailored to your dietary preferences and goals"
                    )
                    
                    featureCard(
                        emoji: "⚖️",
                        title: "Balanced Nutrition",
                        description: "Perfect mix of proteins, carbs, and healthy fats"
                    )
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Action Button - Modern Design
            VStack(spacing: 16) {
                Button(action: {
                    showingMealPlanGeneration = true
                }) {
                    HStack(spacing: 12) {
                        Text("✨")
                            .font(.system(size: 20))
                        
                        Text("Create Your First Plan")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [
                                AppColors.primaryOrange,
                                AppColors.primaryOrange.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                
                Text("It only takes a few minutes to set up")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 32)
            }
        }
    }
    
    // Modern Feature Card Component
    private func featureCard(emoji: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            // Emoji Icon
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primaryOrange.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.text)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.primaryOrange)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.text)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Existing Plans View
    private var existingPlansView: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Enhance My Plan button
            enhancePlanButton
            
            // Show loading overlay only when generating new plans
            ZStack {
                // Meal plan content
                if let activePlan = viewModel.activePlan {
                    mealPlanContent(activePlan)
                } else if let selectedPlan = viewModel.selectedPlan {
                    // Show selected plan if no active plan
                    mealPlanContent(selectedPlan)
                } else if let firstPlan = viewModel.plans.first {
                    // Show first plan if no active or selected plan
                    mealPlanContent(firstPlan)
                } else {
                    // Show empty state if no plans at all
                    emptyActivePlanState
                }
                
                // Subtle loading overlay only for plan generation
                if viewModel.isLoading && viewModel.generationState == .generating {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryOrange))
                        
                        Text("Creating your meal plan...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.text)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                }
            }
        }
    }
    
    // MARK: - UI Components
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Meal Plan")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                

                
                if let activePlan = viewModel.activePlan {
                    Text(formatDateRange(for: activePlan.plan))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                } else if let selectedPlan = viewModel.selectedPlan {
                    Text(formatDateRange(for: selectedPlan.plan))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                } else if let firstPlan = viewModel.plans.first {
                    Text(formatDateRange(for: firstPlan.plan))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Menu button (three dots)
            Button(action: {
                // Show menu options
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.text)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var enhancePlanButton: some View {
        Button(action: {
            showingMealPlanGeneration = true
        }) {
            HStack(spacing: 12) {
                Text("✨")
                    .font(.system(size: 20))
                
                Text("Create New Plan")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [
                        AppColors.primaryOrange,
                        AppColors.primaryOrange.opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    private func mealPlanContent(_ plan: PlanWithRecipes) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Week overview header
                weekOverviewHeader(plan)
                
                // Daily meal sections
                ForEach(getDayMeals(for: plan), id: \.dayOfWeek) { dayMeals in
                    dayMealSection(dayMeals)
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private func weekOverviewHeader(_ plan: PlanWithRecipes) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("📊")
                            .font(.system(size: 20))
                        
                        Text("Week Overview")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.text)
                    }
                    
                    Text("\(plan.mealCount) meals • \(plan.completedMealCount) completed")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Progress indicator with emoji
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(Int(plan.completionPercentage))%")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryOrange)
                        
                        Text(plan.completionPercentage >= 100 ? "🎉" : "📈")
                            .font(.system(size: 16))
                    }
                    
                    Text("Complete")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            
            // Modern Progress bar
            VStack(spacing: 8) {
                ProgressView(value: plan.completionPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(y: 3)
                    .padding(.horizontal, 20)
                
                // Progress text
                if plan.completionPercentage > 0 {
                    Text("Great progress! Keep it up! 🚀")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primaryOrange)
                }
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primaryOrange.opacity(0.08),
                            AppColors.primaryOrange.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primaryOrange.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func dayMealSection(_ dayMeals: PlanDayMeals) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Modern Day header with emoji
            HStack {
                Text(getDayEmoji(dayMeals.dayOfWeek))
                    .font(.system(size: 24))
                
                Text(formatDayHeader(dayMeals.day, dayOfWeek: dayMeals.dayOfWeek))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Check if day has any meals
            let hasMeals = !dayMeals.breakfast.isEmpty || !dayMeals.lunch.isEmpty || !dayMeals.dinner.isEmpty
            
            if hasMeals {
                // Meal entries with modern spacing
                VStack(spacing: 16) {
                    ForEach(dayMeals.breakfast, id: \.id) { recipe in
                        mealEntry(recipe, mealType: "Breakfast")
                    }
                    
                    ForEach(dayMeals.lunch, id: \.id) { recipe in
                        mealEntry(recipe, mealType: "Lunch")
                    }
                    
                    ForEach(dayMeals.dinner, id: \.id) { recipe in
                        mealEntry(recipe, mealType: "Dinner")
                    }
                }
            } else {
                // Modern empty day state
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text("➕")
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("No meals planned")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("Tap to add meals for this day")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(AppColors.textSecondary.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.primaryOrange.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.primaryOrange.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // Helper function to get day emoji
    private func getDayEmoji(_ dayOfWeek: Int) -> String {
        switch dayOfWeek {
        case 0: return "🌅" // Sunday
        case 1: return "☀️" // Monday
        case 2: return "🌤️" // Tuesday
        case 3: return "⛅" // Wednesday
        case 4: return "🌥️" // Thursday
        case 5: return "🌦️" // Friday
        case 6: return "🌈" // Saturday
        default: return "📅"
        }
    }
    
    private func mealEntry(_ recipe: PlanRecipe, mealType: String) -> some View {
        HStack(spacing: 12) {
            // Recipe image - get from the actual recipe if available
            let imageURL = getRecipeImageURL(for: recipe)
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.primaryOrange.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryOrange.opacity(0.5))
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                // Meal type tag
                Text(mealType)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(getMealTypeTagColor(mealType))
                    .clipShape(Capsule())
                
                // Recipe title
                Text(recipe.customMealName ?? "Meal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Options button
            Button(action: {
                // Show meal options
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.primaryOrange.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    VStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(AppColors.primaryOrange)
                                .frame(width: 3, height: 3)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var emptyActivePlanState: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Modern Empty State with Emoji
            VStack(spacing: 20) {
                Text("📅")
                    .font(.system(size: 64))
                
                VStack(spacing: 12) {
                    Text("No Active Plan")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    
                    Text("Create your first meal plan to start your healthy journey")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .padding(.horizontal, 24)
            }
            
            // Modern Action Button
            Button(action: {
                showingMealPlanGeneration = true
            }) {
                HStack(spacing: 12) {
                    Text("✨")
                        .font(.system(size: 20))
                    
                    Text("Create Your Plan")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.primaryOrange,
                            AppColors.primaryOrange.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // Helper method to seed database
    private func seedDatabaseIfNeeded() async {
        do {
            Logger.info("Starting quick database setup")
            let seeder = DatabaseSeeder.shared
            let success = await seeder.seedDatabase()
            if success {
                Logger.info("Database seeded successfully")
                // Refresh templates and plans
                await viewModel.fetchTemplates()
                if let user = authViewModel.user {
                    await viewModel.fetchPlans(for: user.id)
                }
            }
        } catch {
            Logger.error("Failed to seed database: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDateRange(for plan: Plan) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, d"
        let start = formatter.string(from: plan.weekStart)
        let end = formatter.string(from: plan.weekEnd)
        return "\(start) - \(end)"
    }
    
    private func formatDayHeader(_ day: String, dayOfWeek: Int) -> String {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) - 1 // Convert to 0-based
        
        if dayOfWeek == today {
            return "Today, \(day)"
        } else if dayOfWeek == today + 1 {
            return "Tomorrow, \(day)"
        } else {
            return day
        }
    }
    
    private func getDayMeals(for plan: PlanWithRecipes) -> [PlanDayMeals] {
        return viewModel.getDayMeals(for: plan)
    }
    
    private func getMealTypeTagColor(_ mealType: String) -> Color {
        switch mealType.lowercased() {
        case "breakfast":
            return AppColors.primaryOrange
        case "lunch":
            return AppColors.primaryOrange
        case "dinner":
            return AppColors.primaryOrange
        default:
            return AppColors.primaryOrange
        }
    }
    
    /// Gets the recipe image URL for a PlanRecipe by looking up the actual Recipe
    private func getRecipeImageURL(for planRecipe: PlanRecipe) -> URL? {
        // For Spoonacular recipes, we can construct the image URL from the recipe ID
        // Spoonacular recipe images are typically available at: https://spoonacular.com/recipeImages/{id}-556x370.jpg
        
        // First, try to get the Spoonacular ID from the recipe name or custom meal name
        if let recipeId = extractSpoonacularId(from: planRecipe.customMealName ?? "") {
            let imageURLString = "https://spoonacular.com/recipeImages/\(recipeId)-556x370.jpg"
            return URL(string: imageURLString)
        }
        
        // Fallback: return nil to show placeholder
        return nil
    }
    
    /// Extracts Spoonacular recipe ID from meal name (if it contains one)
    private func extractSpoonacularId(from mealName: String) -> String? {
        // Look for patterns that might contain recipe IDs
        // This is a simple approach - in a real app, you'd want to store the Spoonacular ID properly
        let components = mealName.components(separatedBy: " ")
        for component in components {
            if component.count >= 6 && component.allSatisfy({ $0.isNumber }) {
                return component
            }
        }
        return nil
    }
}



#Preview {
    PlansView()
}
