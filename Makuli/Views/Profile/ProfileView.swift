//
//  ProfileView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager

    @StateObject private var profileViewModel = UserProfileViewModel()
    @StateObject private var viewModel = ProfileViewModel()

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var imageToCrop: UIImage?
    @State private var showCropper = false

    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false

    @State private var showingCalorieTarget = false
    @State private var showingMacroTargets = false
    @State private var showingDietPreference = false
    @State private var showingDislikes = false
    @State private var showingFavoriteCuisines = false
    @State private var showingCookingSkills = false
    @State private var showingMealsPerDay = false
    @State private var showingGoal = false
    @State private var showingBudget = false
    @State private var showingDeveloperPanel = false

    @State private var mealReminders = true
    @State private var pushNotifications = true

    @State private var editingName = false
    @State private var editNameText = ""

    @State private var appeared = false

    @State private var pressedRow: String? = nil

    private var user: User? { authViewModel.user }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroHeader
                    statsCard
                        .padding(.horizontal, 20)
                        .offset(y: -20)

                    VStack(spacing: 24) {
                        mealPlanSection
                        appSettingsSection
                        supportSection
                        accountSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .ignoresSafeArea(.all, edges: .top)
            .navigationBarHidden(true)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.65, dampingFraction: 0.85), value: appeared)
        .onAppear { appeared = true }
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
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "") }
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") { viewModel.successMessage = nil }
        } message: { Text(viewModel.successMessage ?? "") }
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
        .sheet(isPresented: $showingDeveloperPanel) {
            DeveloperPanelView()
        }
        .task { await profileViewModel.fetchProfile() }
    }
}

// MARK: - Hero Header

extension ProfileView {

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [AppColors.primaryOrange.opacity(0.15), AppColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: 320)

            VStack(spacing: 16) {
                Spacer().frame(height: 60)

                photoPickerAvatar

                if editingName {
                    HStack(spacing: 8) {
                        TextField("Your name", text: $editNameText)
                            .font(AppFonts.title2())
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppColors.text)
                            .frame(maxWidth: 200)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.card)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.primaryOrange.opacity(0.4), lineWidth: 1.5)
                            )
                        Button {
                            editingName = false
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(AppColors.primaryOrange)
                        }
                    }
                } else {
                    HStack(spacing: 6) {
                        Text(profileViewModel.profile?.name ?? user?.name ?? "Your Name")
                            .font(AppFonts.largeTitle())
                            .foregroundColor(AppColors.text)
                        Button {
                            editNameText = profileViewModel.profile?.name ?? user?.name ?? ""
                            editingName = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        }
                    }
                }

                Text(profileViewModel.profile?.email ?? user?.email ?? "")
                    .font(AppFonts.subheadline())
                    .foregroundColor(AppColors.textSecondary)

                Spacer().frame(height: 28)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var photoPickerAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarImage
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppColors.primaryOrange, AppColors.primaryOrange.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: AppColors.primaryOrange.opacity(0.25), radius: 12, x: 0, y: 4)

            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryOrange)
                        .frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(x: 3, y: 3)
            .onChange(of: selectedItem) { _, item in
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
        ZStack {
            Circle().fill(AppColors.primaryOrange.opacity(0.12))
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(18)
                .foregroundColor(AppColors.primaryOrange.opacity(0.7))
        }
    }
}

// MARK: - Stats Card

extension ProfileView {

    private var statsCard: some View {
        HStack(spacing: 0) {
            statTile(
                value: "\(profileViewModel.profile?.plansCreatedThisMonth ?? 0)",
                label: "Plans Created"
            )
            statDivider
            statTile(
                value: "0",
                label: "Recipes Saved"
            )
            statDivider
            statTile(
                value: "0",
                label: "Week Streak"
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 6)
        )
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.text)
            Text(label)
                .font(AppFonts.caption())
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(AppColors.border)
            .frame(width: 1, height: 36)
    }
}

// MARK: - Settings Sections

extension ProfileView {

    // MARK: Meal Plan Section

    private var mealPlanSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Meal Plan")
            VStack(spacing: 0) {
                settingsRow(
                    id: "diet",
                    icon: "leaf.fill",
                    iconColor: AppColors.successGreen,
                    title: "Diet Preference",
                    value: profileViewModel.profile?.diet ?? user?.diet ?? "—"
                ) { showingDietPreference = true }

                rowDivider

                settingsRow(
                    id: "goal",
                    icon: "target",
                    iconColor: AppColors.primaryOrange,
                    title: "Goal",
                    value: profileViewModel.profile?.goal ?? user?.goal ?? "—"
                ) { showingGoal = true }

                rowDivider

                let mealCount = profileViewModel.profile?.mealPlanningPreferences?.mealsPerDay ?? user?.preferredServings ?? 3
                settingsRow(
                    id: "meals",
                    icon: "fork.knife",
                    iconColor: Color(red: 0.2, green: 0.6, blue: 0.9),
                    title: "Meals per Day",
                    value: "\(mealCount) meal\(mealCount == 1 ? "" : "s")"
                ) { showingMealsPerDay = true }

                rowDivider

                let calories = profileViewModel.profile?.fitnessGoals?.targetCalories ?? 2200
                settingsRow(
                    id: "calories",
                    icon: "flame.fill",
                    iconColor: Color(red: 1.0, green: 0.45, blue: 0.1),
                    title: "Calorie Target",
                    value: "\(calories) kcal"
                ) { showingCalorieTarget = true }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.card)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: App Settings Section

    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("App Settings")
            VStack(spacing: 0) {
                toggleRow(
                    id: "reminders",
                    icon: "bell.fill",
                    iconColor: Color(red: 1.0, green: 0.75, blue: 0.0),
                    title: "Meal Reminders",
                    binding: $mealReminders
                )

                rowDivider

                toggleRow(
                    id: "notifications",
                    icon: "app.badge.fill",
                    iconColor: Color(red: 0.2, green: 0.55, blue: 0.95),
                    title: "Push Notifications",
                    binding: $pushNotifications
                )

                rowDivider

                toggleRow(
                    id: "darkmode",
                    icon: "moon.fill",
                    iconColor: Color(red: 0.38, green: 0.27, blue: 0.78),
                    title: "Dark Mode",
                    binding: Binding(
                        get: { themeManager.isDarkMode },
                        set: { themeManager.setDarkMode($0) }
                    )
                )

                rowDivider

                settingsRow(
                    id: "devpanel",
                    icon: "hammer.fill",
                    iconColor: Color(red: 0.5, green: 0.5, blue: 0.55),
                    title: "Seed Demo Data",
                    value: ""
                ) { showingDeveloperPanel = true }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.card)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Support")
            VStack(spacing: 0) {
                settingsRow(
                    id: "help",
                    icon: "questionmark.circle.fill",
                    iconColor: Color(red: 0.2, green: 0.55, blue: 0.95),
                    title: "Help & Support",
                    value: ""
                ) {}

                rowDivider

                settingsRow(
                    id: "privacy",
                    icon: "hand.raised.fill",
                    iconColor: Color(red: 0.4, green: 0.4, blue: 0.45),
                    title: "Privacy Policy",
                    value: ""
                ) {}

                rowDivider

                settingsRow(
                    id: "terms",
                    icon: "doc.text.fill",
                    iconColor: Color(red: 0.4, green: 0.4, blue: 0.45),
                    title: "Terms of Service",
                    value: ""
                ) {}
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.card)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Account")
            VStack(spacing: 0) {
                Button {
                    showingLogoutAlert = true
                } label: {
                    HStack(spacing: 14) {
                        iconSquare(systemName: "rectangle.portrait.and.arrow.right.fill", color: AppColors.primaryOrange)

                        Text("Log Out")
                            .font(AppFonts.body())
                            .foregroundColor(AppColors.primaryOrange)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(minHeight: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableRowStyle(id: "logout", pressedRow: $pressedRow))

                rowDivider

                Button {
                    showingDeleteAlert = true
                } label: {
                    HStack(spacing: 14) {
                        iconSquare(systemName: "trash.fill", color: .red)

                        Text("Delete Account")
                            .font(AppFonts.body())
                            .foregroundColor(.red)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(minHeight: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableRowStyle(id: "delete", pressedRow: $pressedRow))
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.card)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Row Builders

extension ProfileView {

    private func settingsRow(
        id: String,
        icon: String,
        iconColor: Color,
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                iconSquare(systemName: icon, color: iconColor)

                Text(title)
                    .font(AppFonts.body())
                    .foregroundColor(AppColors.text)

                Spacer()

                if !value.isEmpty {
                    Text(value)
                        .font(AppFonts.subheadline())
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableRowStyle(id: id, pressedRow: $pressedRow))
    }

    private func toggleRow(
        id: String,
        icon: String,
        iconColor: Color,
        title: String,
        binding: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            iconSquare(systemName: icon, color: iconColor)

            Text(title)
                .font(AppFonts.body())
                .foregroundColor(AppColors.text)

            Spacer()

            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(AppColors.primaryOrange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minHeight: 52)
    }

    private func iconSquare(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.15))
                .frame(width: 28, height: 28)
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
    }

    private var rowDivider: some View {
        Divider()
            .padding(.leading, 58)
            .foregroundColor(AppColors.border)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(AppColors.textSecondary)
            .tracking(0.8)
            .padding(.leading, 4)
    }
}

// MARK: - Pressable Row Button Style

private struct PressableRowStyle: ButtonStyle {
    let id: String
    @Binding var pressedRow: String?

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                pressedRow = pressed ? id : nil
            }
    }
}

// MARK: - Computed Summaries

extension ProfileView {

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
