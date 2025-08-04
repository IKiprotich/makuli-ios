//
//  ProfileView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var profileViewModel = UserProfileViewModel()
    @StateObject private var viewModel = ProfileViewModel()
    
    // Profile image selection
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showCropper = false
    @State private var imageToCrop: UIImage?
    
    // Alerts
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingImageUploadSuccess = false
    @State private var showingImageUploadError = false
    
    // Navigation sheets for preference modification
    @State private var showingCalorieTarget = false
    @State private var showingMacroTargets = false
    @State private var showingDietPreference = false
    @State private var showingDislikes = false
    @State private var showingFavoriteCuisines = false
    @State private var showingCookingSkills = false
    @State private var showingMealsPerDay = false
    @State private var showingGoal = false
    @State private var showingBudget = false
    
    // App settings
    @State private var mealReminders = true
    @State private var pushNotifications = true
    @State private var darkMode = false
    
    private var user: User {
        authViewModel.user ?? User(
            id: "",
            email: "",
            fullName: "Guest User",
            profileImageUrl: nil,
            age: 25,
            gender: "Other",
            height: 170.0,
            weight: 70.0,
            activityLevel: "Moderately Active",
            fitnessGoal: "General Health",
            dietaryPreferences: ["Balanced"],
            budgetRange: "$50-75",
            preferredCuisines: [],
            cookingSkillLevel: "Beginner",
            preferredPrepTime: 30,
            preferredServings: 2,
            allergies: [],
            favoriteIngredients: [],
            dislikedIngredients: [],
            hasCompletedOnboarding: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    
                    // Profile Header Section
                    profileHeaderSection
                    
                    // Nutrition Preferences Section
                    nutritionPreferencesSection
                    
                    // Meal Plan Preferences Section
                    mealPlanPreferencesSection
                    
                    // Subscription Section
                    subscriptionSection
                    
                    // App Settings Section
                    appSettingsSection
                    
                    // Support & Legal Section
                    supportLegalSection
                    
                    // Account Actions Section
                    accountActionsSection
                    
                    // Bottom spacing
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(AppColors.getBackground(for: themeManager.colorScheme))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Log Out", isPresented: $showingLogoutAlert){
            Button("Cancel", role: .cancel){}
            Button("Log Out", role: .destructive){
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert){
            Button("Cancel", role: .cancel){}
            Button("Delete", role: .destructive){
                handleDeleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.successMessage = nil
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await profileViewModel.fetchProfile()
        }
        // Navigation sheets for preference modification
        .sheet(isPresented: $showingCalorieTarget) {
            CalorieTargetView(currentValue: profileViewModel.profile?.fitnessGoals?.targetCalories ?? 2200) { newValue in
                handleCalorieTargetUpdate(newValue)
            }
        }
        .sheet(isPresented: $showingMacroTargets) {
            MacroTargetsView(
                currentProtein: Int(profileViewModel.profile?.fitnessGoals?.targetProtein ?? 25),
                currentCarbs: Int(profileViewModel.profile?.fitnessGoals?.targetCarbohydrates ?? 55),
                currentFat: Int(profileViewModel.profile?.fitnessGoals?.targetFat ?? 20)
            ) { protein, carbs, fat in
                handleMacroTargetsUpdate(protein: protein, carbs: carbs, fat: fat)
            }
        }
        .sheet(isPresented: $showingDietPreference) {
            ProfileDietPreferenceView(currentPreference: profileViewModel.profile?.diet ?? user.dietaryPreferences.first ?? "Balanced") { newPreference in
                handleDietPreferenceUpdate(newPreference)
            }
        }
        .sheet(isPresented: $showingDislikes) {
            ProfileDislikesView(currentDislikes: profileViewModel.profile?.dietaryPreferences?.dislikedIngredients ?? user.dislikedIngredients) { newDislikes in
                handleDislikesUpdate(newDislikes)
            }
        }
        .sheet(isPresented: $showingFavoriteCuisines) {
            FavoriteCuisinesView(currentCuisines: profileViewModel.profile?.mealPlanningPreferences?.preferredCuisines ?? user.preferredCuisines) { newCuisines in
                handleFavoriteCuisinesUpdate(newCuisines)
            }
        }
        .sheet(isPresented: $showingCookingSkills) {
            CookingSkillsView(currentSkill: profileViewModel.profile?.cookingPreferences?.skillLevel ?? user.cookingSkillLevel) { newSkill in
                handleCookingSkillsUpdate(newSkill)
            }
        }
        .sheet(isPresented: $showingMealsPerDay) {
            MealsPerDayView(currentMeals: profileViewModel.profile?.mealPlanningPreferences?.mealsPerDay ?? user.preferredServings) { newMeals in
                handleMealsPerDayUpdate(newMeals)
            }
        }
        .sheet(isPresented: $showingGoal) {
            GoalView(currentGoal: profileViewModel.profile?.goal ?? user.goal) { newGoal in
                handleGoalUpdate(newGoal)
            }
        }
        .sheet(isPresented: $showingBudget) {
            BudgetView(currentBudget: profileViewModel.profile?.budget ?? user.budget) { newBudget in
                handleBudgetUpdate(newBudget)
            }
        }
    }
}

// MARK: - ProfileView Extensions
extension ProfileView {
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Profile Image
            ZStack(alignment: .bottomTrailing) {
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                } else if let url = profileViewModel.profile?.profileImageUrl, let imageUrl = URL(string: url) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 120, height: 120)
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .foregroundColor(AppColors.primaryOrange.opacity(0.3))
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryOrange)
                            .frame(width: 36, height: 36)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .offset(x: 8, y: 8)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            if let uiImage = UIImage(data: data) {
                                imageToCrop = uiImage
                                showCropper = true
                            }
                        }
                    }
                }
            }
            .frame(width: 120, height: 120)
            .sheet(isPresented: $showCropper) {
                if let image = imageToCrop {
                    ImageCropperView(image: image) { croppedImage in
                        if let imageData = croppedImage.jpegData(compressionQuality: 0.8) {
                            selectedImageData = imageData
                            // Upload the cropped image
                            Task {
                                let success = await viewModel.uploadProfileImage(imageData, userId: user.id)
                                if success {
                                    showingImageUploadSuccess = true
                                } else {
                                    showingImageUploadError = true
                                }
                            }
                        }
                    }
                }
            }
            
            // User Info
            VStack(spacing: 12) {
                if profileViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                } else if let error = profileViewModel.error {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if let profile = profileViewModel.profile {
                    Text(profile.name ?? "No Name")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(profile.email ?? user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Profile not found")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                }
                
                // Edit Profile Button
                Button(action: handleEditProfile) {
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryOrange)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.primaryOrange, lineWidth: 1.5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Nutrition Preferences Section
    private var nutritionPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Nutrition", icon: "flame.fill")
            
            VStack(spacing: 12) {
                // Goal
                ProfileRowView(
                    icon: "target",
                    iconColor: AppColors.primaryOrange,
                    title: "Goal",
                    value: profileViewModel.profile?.goal ?? user.goal,
                    showChevron: true
                ) {
                    showingGoal = true
                }
                
                // Budget
                ProfileRowView(
                    icon: "dollarsign.circle.fill",
                    iconColor: AppColors.successGreen,
                    title: "Budget",
                    value: profileViewModel.profile?.budget ?? user.budget,
                    showChevron: true
                ) {
                    showingBudget = true
                }
                
                // Calorie target
                let calorieTarget = profileViewModel.profile?.fitnessGoals?.targetCalories ?? 2200
                ProfileRowView(
                    icon: "flame.fill",
                    iconColor: AppColors.primaryOrange,
                    title: "Calorie target",
                    value: "\(calorieTarget) kcal",
                    showChevron: true
                ) {
                    showingCalorieTarget = true
                }
                
                // Macro targets
                let protein = Int(profileViewModel.profile?.fitnessGoals?.targetProtein ?? 25)
                let carbs = Int(profileViewModel.profile?.fitnessGoals?.targetCarbohydrates ?? 55)
                let fat = Int(profileViewModel.profile?.fitnessGoals?.targetFat ?? 20)
                ProfileRowView(
                    icon: "chart.pie.fill",
                    iconColor: AppColors.successGreen,
                    title: "Macro targets",
                    value: "\(protein)%, \(carbs)%, \(fat)%",
                    showChevron: true
                ) {
                    showingMacroTargets = true
                }
                
                // Diet preference
                let dietPreference = profileViewModel.profile?.diet ?? user.dietaryPreferences.first ?? "Balanced"
                ProfileRowView(
                    icon: "leaf.fill",
                    iconColor: AppColors.successGreen,
                    title: "Diet preference",
                    value: dietPreference,
                    showChevron: true
                ) {
                    showingDietPreference = true
                }
                
                // Dislikes
                let dislikesCount = profileViewModel.profile?.dietaryPreferences?.dislikedIngredients.count ?? user.dislikedIngredients.count
                ProfileRowView(
                    icon: "xmark.circle.fill",
                    iconColor: AppColors.warnRed,
                    title: "Dislikes",
                    value: "\(dislikesCount) ingredient\(dislikesCount == 1 ? "" : "s")",
                    showChevron: true
                ) {
                    showingDislikes = true
                }
                
                // Favorite cuisines
                let cuisinesCount = profileViewModel.profile?.mealPlanningPreferences?.preferredCuisines.count ?? user.preferredCuisines.count
                ProfileRowView(
                    icon: "hand.thumbsup.fill",
                    iconColor: AppColors.primaryOrange,
                    title: "Favorite cuisines",
                    value: "\(cuisinesCount) cuisine\(cuisinesCount == 1 ? "" : "s")",
                    showChevron: true
                ) {
                    showingFavoriteCuisines = true
                }
                
                // Cooking skills
                let cookingSkill = profileViewModel.profile?.cookingPreferences?.skillLevel ?? user.cookingSkillLevel
                ProfileRowView(
                    icon: "fork.knife.circle.fill",
                    iconColor: AppColors.primaryOrange,
                    title: "Cooking skills",
                    value: cookingSkill,
                    showChevron: true
                ) {
                    showingCookingSkills = true
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Meal Plan Preferences Section
    private var mealPlanPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Meal Plan", icon: "calendar")
            
            VStack(spacing: 12) {
                // Meals per day
                let mealsPerDay = profileViewModel.profile?.mealPlanningPreferences?.mealsPerDay ?? user.preferredServings
                ProfileRowView(
                    icon: "list.bullet",
                    iconColor: AppColors.primaryOrange,
                    title: "Meals per day",
                    value: "\(mealsPerDay) meal\(mealsPerDay == 1 ? "" : "s")",
                    showChevron: true
                ) {
                    showingMealsPerDay = true
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Subscription", icon: "crown.fill")
            
            VStack(spacing: 12) {
                if user.isPremium {
                    ProfileRowView(title: "Plan", value: "Premium")
                    
                    Button("Manage Subscription") {
                        // TODO: Handle subscription management
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemBackground))
                    .foregroundColor(AppColors.primaryOrange)
                    .cornerRadius(12)
                    .fontWeight(.medium)
                } else {
                    ProfileRowView(title: "Plan", value: "Free")
                    
                    Button("Upgrade to Premium") {
                        // TODO: Handle premium upgrade
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.primaryOrange, AppColors.primaryOrange.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                    .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - App Settings Section
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("App Settings", icon: "gearshape.fill")
            
            VStack(spacing: 12) {
                ProfileRowView(title: "Meal Reminder", toggleValue: $mealReminders)
                
                ProfileRowView(title: "Push Notifications", toggleValue: $pushNotifications)
                
                ProfileRowView(title: "Dark Mode", toggleValue: $darkMode)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Support and Legal Section
    private var supportLegalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Support & Legal", icon: "questionmark.circle.fill")
            
            VStack(spacing: 12) {
                ProfileRowView(icon: "questionmark.circle.fill",
                               iconColor:.blue,
                               title: "Help & Support",
                               value: "",
                               showChevron: true) {
                    // TODO: Handle help & support
                }
                
                ProfileRowView(icon: "doc.text.fill",
                               iconColor: .gray,
                               title: "Privacy Policy",
                               value: "",
                               showChevron: true) {
                    // TODO: Handle privacy policy
                }
                
                ProfileRowView(icon: "doc.text.fill",
                               iconColor: .gray,
                               title: "Terms of Service",
                               value: "",
                               showChevron: true) {
                    // TODO: Handle terms of service
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Account Actions Section
    private var accountActionsSection: some View {
        VStack(spacing: 16) {
            // Log Out Button
            Button(action: handleLogout) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                    Text("Log Out")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.8), AppColors.primaryOrange]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            // Delete Account Button
            Button(action: handleDeleteAccount) {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                    Text("Delete Account")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    /// Helper view for section headers with an icon and title.
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryOrange)
                .font(.system(size: 20, weight: .medium))
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Action Handlers
    
    /// Handles logout action
    private func handleLogout() {
        Task {
            await authViewModel.signOut()
        }
    }
    
    /// Handles delete account action
    private func handleDeleteAccount() {
        Task {
            let success = await viewModel.deleteAccount(userId: user.id)
            if success {
                await authViewModel.signOut()
            }
        }
    }
    
    /// Handles edit profile action
    private func handleEditProfile() {
        // TODO: Implement edit profile functionality
        Logger.debug("Edit profile tapped")
    }
    
    // MARK: - Nutrition and Meal Plan Update Handlers
    
    /// Handles calorie target update
    private func handleCalorieTargetUpdate(_ newValue: Int) {
        Task {
            let success = await viewModel.updateCalorieTarget(newValue)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles macro targets update
    private func handleMacroTargetsUpdate(protein: Int, carbs: Int, fat: Int) {
        Task {
            let success = await viewModel.updateMacroTargets(protein: protein, carbs: carbs, fat: fat)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles diet preference update
    private func handleDietPreferenceUpdate(_ newPreference: String) {
        Task {
            let success = await viewModel.updateDietPreference(newPreference)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles dislikes update
    private func handleDislikesUpdate(_ newDislikes: [String]) {
        Task {
            let success = await viewModel.updateDislikedIngredients(newDislikes)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles favorite cuisines update
    private func handleFavoriteCuisinesUpdate(_ newCuisines: [String]) {
        Task {
            let success = await viewModel.updatePreferredCuisines(newCuisines)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles cooking skills update
    private func handleCookingSkillsUpdate(_ newSkill: String) {
        Task {
            let success = await viewModel.updateCookingSkill(newSkill)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles meals per day update
    private func handleMealsPerDayUpdate(_ newMeals: Int) {
        Task {
            let success = await viewModel.updateMealsPerDay(newMeals)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles goal update
    private func handleGoalUpdate(_ newGoal: String) {
        Task {
            let success = await viewModel.updateGoal(newGoal)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
    
    /// Handles budget update
    private func handleBudgetUpdate(_ newBudget: String) {
        Task {
            let success = await viewModel.updateBudget(newBudget)
            if success {
                // Refresh the profile to show updated values
                await profileViewModel.forceRefreshProfile()
            }
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
}
