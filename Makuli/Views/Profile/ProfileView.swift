//
//  ProfileView.swift
//  Makuli
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager

    // Single ViewModel that owns both profile data and update actions
    @StateObject private var profileViewModel = UserProfileViewModel()
    @StateObject private var viewModel = ProfileViewModel()

    // Photo picker
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var imageToCrop: UIImage?
    @State private var showCropper = false

    // Destructive action confirmations
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false

    // Preference sheets
    @State private var showingCalorieTarget = false
    @State private var showingMacroTargets = false
    @State private var showingDietPreference = false
    @State private var showingDislikes = false
    @State private var showingFavoriteCuisines = false
    @State private var showingCookingSkills = false
    @State private var showingMealsPerDay = false
    @State private var showingGoal = false
    @State private var showingBudget = false

    // Notification toggles (backed by UserDefaults in a real app)
    @State private var mealReminders = true
    @State private var pushNotifications = true

    private var user: User? { authViewModel.user }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    profileHeaderSection
                        .padding(.bottom, 28)

                    sectionGroup("Nutrition", icon: "flame.fill") {
                        nutritionRows
                    }

                    sectionGroup("Meal Plan", icon: "calendar") {
                        mealPlanRows
                    }

                    sectionGroup("Subscription", icon: "crown.fill") {
                        subscriptionRows
                    }

                    sectionGroup("App Settings", icon: "gearshape.fill") {
                        settingsRows
                    }

                    sectionGroup("Support & Legal", icon: "questionmark.circle.fill") {
                        supportRows
                    }

                    accountActions
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        // Confirmations
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) { Task { await authViewModel.signOut() } }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    guard let id = user?.id else { return }
                    let ok = await viewModel.deleteAccount(userId: id)
                    if ok { await authViewModel.signOut() }
                }
            }
        } message: {
            Text("This action is permanent. All your data will be deleted.")
        }
        // Error / success feedback
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") { viewModel.successMessage = nil }
        } message: { Text(viewModel.successMessage ?? "") }
        // Preference sheets
        .sheet(isPresented: $showingCalorieTarget) {
            CalorieTargetView(currentValue: profileViewModel.profile?.fitnessGoals?.targetCalories ?? 2200) { newValue in
                Task {
                    let ok = await viewModel.updateCalorieTarget(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingMacroTargets) {
            MacroTargetsView(
                currentProtein: Int(profileViewModel.profile?.fitnessGoals?.targetProtein ?? 25),
                currentCarbs: Int(profileViewModel.profile?.fitnessGoals?.targetCarbohydrates ?? 55),
                currentFat: Int(profileViewModel.profile?.fitnessGoals?.targetFat ?? 20)
            ) { p, c, f in
                Task {
                    let ok = await viewModel.updateMacroTargets(protein: p, carbs: c, fat: f)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingDietPreference) {
            ProfileDietPreferenceView(
                currentPreference: profileViewModel.profile?.diet ?? user?.diet ?? "Balanced"
            ) { newValue in
                Task {
                    let ok = await viewModel.updateDietPreference(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingDislikes) {
            ProfileDislikesView(
                currentDislikes: profileViewModel.profile?.dietaryPreferences?.dislikedIngredients ?? user?.dislikedIngredients ?? []
            ) { newValue in
                Task {
                    let ok = await viewModel.updateDislikedIngredients(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingFavoriteCuisines) {
            FavoriteCuisinesView(
                currentCuisines: profileViewModel.profile?.mealPlanningPreferences?.preferredCuisines ?? user?.preferredCuisines ?? []
            ) { newValue in
                Task {
                    let ok = await viewModel.updatePreferredCuisines(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingCookingSkills) {
            CookingSkillsView(
                currentSkill: profileViewModel.profile?.cookingPreferences?.skillLevel ?? user?.cookingSkillLevel ?? "Beginner"
            ) { newValue in
                Task {
                    let ok = await viewModel.updateCookingSkill(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingMealsPerDay) {
            MealsPerDayView(
                currentMeals: profileViewModel.profile?.mealPlanningPreferences?.mealsPerDay ?? user?.preferredServings ?? 3
            ) { newValue in
                Task {
                    let ok = await viewModel.updateMealsPerDay(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingGoal) {
            GoalView(currentGoal: profileViewModel.profile?.goal ?? user?.goal ?? "") { newValue in
                Task {
                    let ok = await viewModel.updateGoal(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showingBudget) {
            BudgetView(currentBudget: profileViewModel.profile?.budget ?? user?.budget ?? "") { newValue in
                Task {
                    let ok = await viewModel.updateBudget(newValue)
                    if ok { await profileViewModel.forceRefreshProfile() }
                }
            }
        }
        .sheet(isPresented: $showCropper) {
            if let image = imageToCrop {
                ImageCropperView(image: image) { cropped in
                    if let data = cropped.jpegData(compressionQuality: 0.8) {
                        selectedImageData = data
                        Task {
                            guard let id = user?.id else { return }
                            await viewModel.uploadProfileImage(data, userId: id)
                            await profileViewModel.forceRefreshProfile()
                        }
                    }
                }
            }
        }
        .task { await profileViewModel.fetchProfile() }
    }
}

// MARK: - Sections

extension ProfileView {

    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                avatarImage
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.surface, lineWidth: 3))
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(AppColors.primaryOrange)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                }
                .offset(x: 4, y: 4)
                .onChange(of: selectedItem) { item in
                    Task {
                        if let data = try? await item?.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            selectedImageData = data
                            imageToCrop = ui
                            showCropper = true
                        }
                    }
                }
            }

            // Name & email
            if profileViewModel.isLoading {
                ProgressView()
            } else if let profile = profileViewModel.profile {
                VStack(spacing: 4) {
                    Text(profile.name ?? "—")
                        .font(.title2).fontWeight(.semibold)
                        .foregroundColor(AppColors.text)
                    Text(profile.email ?? user?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                Text("Profile unavailable")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let data = selectedImageData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().aspectRatio(contentMode: .fill)
        } else if let urlString = profileViewModel.profile?.profileImageUrl,
                  let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if let img = phase.image {
                    img.resizable().aspectRatio(contentMode: .fill)
                } else {
                    defaultAvatar
                }
            }
        } else {
            defaultAvatar
        }
    }

    private var defaultAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .foregroundColor(AppColors.primaryOrange.opacity(0.4))
    }

    // MARK: - Row Groups

    private var nutritionRows: some View {
        Group {
            ProfileRowView(icon: "target",                 iconColor: AppColors.primaryOrange, title: "Goal",             value: profileViewModel.profile?.goal ?? user?.goal ?? "—",              showChevron: true) { showingGoal = true }
            ProfileRowView(icon: "dollarsign.circle.fill", iconColor: AppColors.successGreen,  title: "Budget",           value: profileViewModel.profile?.budget ?? user?.budget ?? "—",          showChevron: true) { showingBudget = true }
            ProfileRowView(icon: "flame.fill",             iconColor: AppColors.primaryOrange, title: "Calorie target",   value: "\(profileViewModel.profile?.fitnessGoals?.targetCalories ?? 2200) kcal", showChevron: true) { showingCalorieTarget = true }
            ProfileRowView(icon: "chart.pie.fill",         iconColor: AppColors.successGreen,  title: "Macro targets",    value: macroSummary,                                                      showChevron: true) { showingMacroTargets = true }
            ProfileRowView(icon: "leaf.fill",              iconColor: AppColors.successGreen,  title: "Diet preference",  value: profileViewModel.profile?.diet ?? user?.diet ?? "—",              showChevron: true) { showingDietPreference = true }
            ProfileRowView(icon: "xmark.circle.fill",      iconColor: AppColors.warnRed,       title: "Dislikes",         value: dislikesSummary,                                                   showChevron: true) { showingDislikes = true }
            ProfileRowView(icon: "hand.thumbsup.fill",     iconColor: AppColors.primaryOrange, title: "Favourite cuisines", value: cuisinesSummary,                                               showChevron: true) { showingFavoriteCuisines = true }
            ProfileRowView(icon: "fork.knife.circle.fill", iconColor: AppColors.primaryOrange, title: "Cooking skill",    value: profileViewModel.profile?.cookingPreferences?.skillLevel ?? user?.cookingSkillLevel ?? "—", showChevron: true) { showingCookingSkills = true }
        }
    }

    private var mealPlanRows: some View {
        let count = profileViewModel.profile?.mealPlanningPreferences?.mealsPerDay ?? user?.preferredServings ?? 3
        return ProfileRowView(icon: "list.bullet", iconColor: AppColors.primaryOrange, title: "Meals per day", value: "\(count) meal\(count == 1 ? "" : "s")", showChevron: true) { showingMealsPerDay = true }
    }

    private var subscriptionRows: some View {
        Group {
            ProfileRowView(title: "Plan", value: (user?.isPremium == true) ? "Premium" : "Free")

            Button(user?.isPremium == true ? "Manage Subscription" : "Upgrade to Premium") {}
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(user?.isPremium == true ? AppColors.surface : AppColors.primaryOrange)
                .foregroundColor(user?.isPremium == true ? AppColors.primaryOrange : .white)
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
        }
    }

    private var settingsRows: some View {
        Group {
            ProfileRowView(title: "Meal Reminders",    toggleValue: $mealReminders)
            ProfileRowView(title: "Push Notifications", toggleValue: $pushNotifications)
            ProfileRowView(title: "Dark Mode", toggleValue: Binding(
                get: { themeManager.isDarkMode },
                set: { themeManager.setDarkMode($0) }
            ))
        }
    }

    private var supportRows: some View {
        Group {
            ProfileRowView(icon: "questionmark.circle.fill", iconColor: .blue,   title: "Help & Support",   value: "", showChevron: true) {}
            ProfileRowView(icon: "doc.text.fill",            iconColor: .gray,   title: "Privacy Policy",   value: "", showChevron: true) {}
            ProfileRowView(icon: "doc.text.fill",            iconColor: .gray,   title: "Terms of Service", value: "", showChevron: true) {}
        }
    }

    private var accountActions: some View {
        VStack(spacing: 12) {
            Button {
                showingLogoutAlert = true
            } label: {
                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.primaryOrange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete Account", systemImage: "trash")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
            }
        }
    }

    // MARK: - Section Container

    private func sectionGroup<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primaryOrange)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(AppFonts.title2())
                    .foregroundColor(AppColors.text)
            }
            .padding(.top, 20)

            VStack(spacing: 0) {
                content()
            }
            .background(AppColors.card)
            .cornerRadius(12)
        }
    }

    // MARK: - Computed Summaries

    private var macroSummary: String {
        let p = Int(profileViewModel.profile?.fitnessGoals?.targetProtein ?? 25)
        let c = Int(profileViewModel.profile?.fitnessGoals?.targetCarbohydrates ?? 55)
        let f = Int(profileViewModel.profile?.fitnessGoals?.targetFat ?? 20)
        return "\(p)P · \(c)C · \(f)F"
    }

    private var dislikesSummary: String {
        let count = profileViewModel.profile?.dietaryPreferences?.dislikedIngredients.count
            ?? user?.dislikedIngredients.count ?? 0
        return count == 0 ? "None" : "\(count) ingredient\(count == 1 ? "" : "s")"
    }

    private var cuisinesSummary: String {
        let count = profileViewModel.profile?.mealPlanningPreferences?.preferredCuisines.count
            ?? user?.preferredCuisines.count ?? 0
        return count == 0 ? "None" : "\(count) cuisine\(count == 1 ? "" : "s")"
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
}
