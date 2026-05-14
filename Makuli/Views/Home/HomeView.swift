//
//  HomeView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var profileViewModel = UserProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var contentAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        greetingHeader

                        if viewModel.isLoading && !viewModel.hasActivePlan {
                            skeletonSection
                        } else if viewModel.hasActivePlan {
                            todayHeroCard
                            todayMealsSection
                            if !viewModel.upcomingMeals.isEmpty {
                                upcomingSection
                            }
                        } else {
                            emptyPlanCard
                        }

                        quickActionsSection

                        if !viewModel.quickRecipes.isEmpty {
                            discoverSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 20)
                    .animation(.spring(response: 0.65, dampingFraction: 0.85), value: contentAppeared)
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.navigateToWeekDetail) {
                if let plan = viewModel.currentPlan {
                    Text("Week Detail — \(plan.plan.title)")
                } else {
                    EmptyPlanView()
                }
            }
            .sheet(isPresented: $viewModel.showingPlanCreation) { PlanCreationView() }
            .sheet(isPresented: $viewModel.showingGroceryList)  { GroceryListView()  }
            .task {
                if let user = authViewModel.user {
                    await viewModel.loadDashboardData(for: user.id)
                    await profileViewModel.fetchProfile()
                    profileViewModel.startListeningForUpdates()
                }
                withAnimation(.spring(response: 0.65, dampingFraction: 0.85)) {
                    contentAppeared = true
                }
            }
            .refreshable {
                if let user = authViewModel.user {
                    await viewModel.refreshDashboard(for: user.id)
                    await profileViewModel.forceRefreshProfile()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                if let msg = viewModel.errorMessage { Text(msg) }
            }
        }
        .onDisappear { profileViewModel.stopListeningForUpdates() }
    }
}

// MARK: - Section Builders

extension HomeView {

    private var greetingHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.6)

                Text(viewModel.timeBasedGreeting)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.text)

                if let name = profileViewModel.profile?.name {
                    Text(name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.primaryOrange)
                }
            }

            Spacer()

            Button {
                viewModel.handleProfileTap(selectedTab: $selectedTab)
            } label: {
                Group {
                    if let urlStr = profileViewModel.profile?.profileImageUrl,
                       let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            if let img = phase.image {
                                img.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                avatarPlaceholder
                            }
                        }
                    } else {
                        avatarPlaceholder
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(AppColors.primaryOrange.opacity(0.35), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle().fill(AppColors.primaryOrange.opacity(0.12))
            Image(systemName: "person.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(AppColors.primaryOrange)
        }
    }

    private var todayHeroCard: some View {
        let status = viewModel.todaysCompletionStatus
        let (wCompleted, wTotal, _) = viewModel.weekProgress

        return ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primaryOrange,
                            Color(red: 1.0, green: 0.42, blue: 0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 200, height: 200)
                .offset(x: 130, y: -70)

            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 130, height: 130)
                .offset(x: -90, y: 90)

            VStack(spacing: 22) {

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 5) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))
                            Text("Today")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                                .textCase(.uppercase)
                                .tracking(1)
                        }

                        if status.total == 0 {
                            Text("No meals\nscheduled today")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineSpacing(2)
                        } else {
                            Text("\(status.completed) of \(status.total)\nmeals complete")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineSpacing(2)
                        }

                        Text(viewModel.getMotivationalMessage())
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.22), lineWidth: 7)

                        Circle()
                            .trim(from: 0, to: min(status.percentage / 100, 1.0))
                            .stroke(
                                .white,
                                style: StrokeStyle(lineWidth: 7, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(
                                .spring(response: 1.4, dampingFraction: 0.75),
                                value: status.percentage
                            )

                        VStack(spacing: 1) {
                            Text("\(Int(status.percentage))%")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("done")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .frame(width: 76, height: 76)
                }

                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(height: 1)
                    .cornerRadius(1)

                HStack(spacing: 0) {
                    ForEach(0..<7) { i in
                        let dow = (i + 1) % 7
                        WeekDayDot(
                            dayIndex: i,
                            isToday: isToday(dow),
                            completionFraction: dayCompletionFraction(dow)
                        )
                        if i < 6 { Spacer() }
                    }
                }

                HStack {
                    Label(
                        "\(wCompleted)/\(wTotal) this week",
                        systemImage: "chart.bar.fill"
                    )
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))

                    Spacer()

                    Button(action: viewModel.handleCurrentPlanTap) {
                        HStack(spacing: 4) {
                            Text("View Plan")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.2), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(22)
        }
        .shadow(
            color: AppColors.primaryOrange.opacity(0.45),
            radius: 24, x: 0, y: 12
        )
    }

    private var todayMealsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: "Today's Menu",
                icon: "fork.knife",
                badge: viewModel.todaysMeals.isEmpty ? nil : "\(viewModel.todaysMeals.count)"
            )

            if viewModel.isLoading {
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { _ in ShimmerMealRow() }
                }
            } else if viewModel.todaysMeals.isEmpty {
                noMealsTodayView
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.todaysMeals, id: \.id) { meal in
                        PremiumMealRow(meal: meal) {
                            Task { await viewModel.toggleMealCompletion(meal) }
                        }
                    }
                }
            }
        }
    }

    private var noMealsTodayView: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryOrange.opacity(0.1))
                    .frame(width: 52, height: 52)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(AppColors.primaryOrange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Free day!")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.text)
                Text("No meals scheduled today. Check tomorrow's plan.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(18)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 5)
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Coming Up", icon: "clock.arrow.2.circlepath")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(viewModel.upcomingMeals.prefix(6)), id: \.id) { meal in
                        UpcomingMealPill(meal: meal)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
    }

    private var emptyPlanCard: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryOrange.opacity(0.08))
                    .frame(width: 96, height: 96)
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(AppColors.primaryOrange)
            }

            VStack(spacing: 10) {
                Text("Start meal planning")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.text)
                Text("Create your first weekly plan and get personalised recipes for every meal.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 10) {
                ForEach(emptyStateFeatures, id: \.0) { icon, text in
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.primaryOrange)
                            .frame(width: 24)
                        Text(text)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 4)

            Button(action: viewModel.handlePlanCreationTap) {
                Label("Create My First Plan", systemImage: "plus")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.primaryOrange)
                            .shadow(
                                color: AppColors.primaryOrange.opacity(0.4),
                                radius: 14, x: 0, y: 7
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(26)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 8)
    }

    private var emptyStateFeatures: [(String, String)] {
        [
            ("calendar.badge.checkmark", "7-day meal plans tailored to you"),
            ("cart",                     "Auto-generated grocery lists"),
            ("fork.knife",               "Hundreds of curated recipes"),
        ]
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Quick Actions", icon: "bolt.fill")

            HStack(spacing: 12) {
                QuickActionTile(
                    icon: viewModel.hasActivePlan
                        ? "calendar.badge.checkmark"
                        : "calendar.badge.plus",
                    label: viewModel.hasActivePlan ? "My Plan" : "New Plan",
                    color: AppColors.primaryOrange
                ) {
                    if viewModel.hasActivePlan {
                        viewModel.handleCurrentPlanTap()
                    } else {
                        viewModel.handlePlanCreationTap()
                    }
                }

                QuickActionTile(
                    icon: "cart",
                    label: groceryLabel,
                    color: Color.teal
                ) {
                    viewModel.handleGroceryListTap()
                }

                QuickActionTile(
                    icon: "magnifyingglass",
                    label: "Discover",
                    color: Color.indigo
                ) {
                    viewModel.handleExploreRecipesTap(selectedTab: $selectedTab)
                }
            }
        }
    }

    private var groceryLabel: String {
        let s = viewModel.groceryStats
        return s.totalItems > 0 ? "\(s.checkedItems)/\(s.totalItems)" : "Groceries"
    }

    private var discoverSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                sectionHeader(title: "Discover", icon: "sparkles")
                Spacer()
                Button {
                    viewModel.handleExploreRecipesTap(selectedTab: $selectedTab)
                } label: {
                    Text("See All")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.primaryOrange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.primaryOrange.opacity(0.1), in: Capsule())
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.quickRecipes, id: \.id) { recipe in
                        DiscoverRecipeCard(recipe: recipe)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
    }

    private var skeletonSection: some View {
        VStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { _ in ShimmerMealRow() }
        }
    }

    @ViewBuilder
    private func sectionHeader(
        title: String,
        icon: String,
        badge: String? = nil
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.primaryOrange)

            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.text)

            if let badge {
                Text(badge)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(AppColors.primaryOrange, in: Capsule())
            }
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: Date())
    }

    private func isToday(_ dayOfWeek: Int) -> Bool {
        Calendar.current.component(.weekday, from: Date()) - 1 == dayOfWeek
    }

    private func dayCompletionFraction(_ dayOfWeek: Int) -> Double {
        guard let plan = viewModel.currentPlan else { return 0 }
        let meals = plan.recipes.filter { $0.dayOfWeek == dayOfWeek }
        guard !meals.isEmpty else { return 0 }
        return Double(meals.filter(\.isCompleted).count) / Double(meals.count)
    }
}

// MARK: - Week Day Dot

private struct WeekDayDot: View {
    let dayIndex: Int
    let isToday: Bool
    let completionFraction: Double

    private static let initials = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(spacing: 5) {
            Text(Self.initials[dayIndex])
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(isToday ? .white : .white.opacity(0.65))

            ZStack {
                Circle()
                    .fill(.white.opacity(isToday ? 0.28 : 0.14))
                    .frame(width: 28, height: 28)

                if completionFraction >= 1.0 {
                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.primaryOrange)
                } else if completionFraction > 0 {
                    Circle()
                        .trim(from: 0, to: completionFraction)
                        .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 22, height: 22)
                        .rotationEffect(.degrees(-90))
                }

                if isToday {
                    Circle()
                        .strokeBorder(.white, lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
            }
        }
    }
}

// MARK: - Premium Meal Row

struct PremiumMealRow: View {
    let meal: PlanRecipe
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(mealColor.opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: mealIcon)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(mealColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.customMealName ?? "Meal")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.text)
                    .strikethrough(meal.isCompleted, color: AppColors.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(meal.mealType.capitalized)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(mealColor)

                    if let t = meal.customCookTime, t > 0 {
                        Circle()
                            .fill(AppColors.textSecondary.opacity(0.4))
                            .frame(width: 3, height: 3)
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundStyle(AppColors.textSecondary)
                        Text("\(t) min")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            Spacer()

            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(
                            meal.isCompleted
                                ? AppColors.successGreen
                                : AppColors.border.opacity(0.45)
                        )
                        .frame(width: 32, height: 32)

                    if meal.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .strokeBorder(AppColors.border, lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: meal.isCompleted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 18))
        .shadow(
            color: .black.opacity(meal.isCompleted ? 0.02 : 0.055),
            radius: 12, x: 0, y: 5
        )
        .opacity(meal.isCompleted ? 0.72 : 1.0)
        .animation(.easeInOut(duration: 0.22), value: meal.isCompleted)
    }

    private var mealColor: Color {
        switch meal.mealType.lowercased() {
        case "breakfast": return .orange
        case "lunch":     return .teal
        case "dinner":    return .indigo
        default:          return .purple
        }
    }

    private var mealIcon: String {
        switch meal.mealType.lowercased() {
        case "breakfast": return "sun.horizon.fill"
        case "lunch":     return "sun.max.fill"
        case "dinner":    return "moon.stars.fill"
        default:          return "leaf.fill"
        }
    }
}

// MARK: - Upcoming Meal Pill

private struct UpcomingMealPill: View {
    let meal: PlanRecipe

    var body: some View {
        HStack(spacing: 9) {
            ZStack {
                Circle()
                    .fill(mealColor.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: mealIcon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(mealColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.customMealName ?? "Meal")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.text)
                    .lineLimit(1)
                Text(meal.day)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .padding(.vertical, 9)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var mealColor: Color {
        switch meal.mealType.lowercased() {
        case "breakfast": return .orange
        case "lunch":     return .teal
        case "dinner":    return .indigo
        default:          return .purple
        }
    }

    private var mealIcon: String {
        switch meal.mealType.lowercased() {
        case "breakfast": return "sun.horizon.fill"
        case "lunch":     return "sun.max.fill"
        case "dinner":    return "moon.stars.fill"
        default:          return "leaf.fill"
        }
    }
}

// MARK: - Quick Action Tile

private struct QuickActionTile: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.text)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppColors.card, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.055), radius: 12, x: 0, y: 5)
            .scaleEffect(pressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded   { _ in pressed = false }
        )
    }
}

// MARK: - Discover Recipe Card

private struct DiscoverRecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: recipe.validImageURL) { phase in
                if let img = phase.image {
                    img.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(AppColors.primaryOrange.opacity(0.08))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.system(size: 26, weight: .ultraLight))
                                .foregroundStyle(AppColors.primaryOrange.opacity(0.35))
                        )
                }
            }
            .frame(width: 162, height: 108)
            .clipped()
            .clipShape(.rect(
                topLeadingRadius: 18,
                bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 18
            ))

            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    if let ct = recipe.cookTime {
                        Label(ct, systemImage: "clock")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    if let cal = recipe.calories {
                        if recipe.cookTime != nil {
                            Text("·")
                                .font(.system(size: 11))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Label("\(cal) cal", systemImage: "flame")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
        }
        .frame(width: 162)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 6)
    }
}

// MARK: - Shimmer Loading Row

private struct ShimmerMealRow: View {
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 13)
                .fill(shimmerGradient)
                .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 7) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(shimmerGradient)
                    .frame(height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .fill(shimmerGradient)
                    .frame(width: 90, height: 10)
            }

            Spacer()

            Circle()
                .fill(shimmerGradient)
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 18))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColors.border.opacity(0.45),
                AppColors.border.opacity(0.2),
                AppColors.border.opacity(0.45)
            ],
            startPoint: shimmer ? .topLeading : .bottomTrailing,
            endPoint: shimmer ? .bottomTrailing : .topLeading
        )
    }
}

// MARK: - Supporting Types

struct ProgressMetric {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
}

struct EmptyPlanView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.textSecondary)
            Text("No Active Plan")
                .font(AppFonts.title2())
                .foregroundStyle(AppColors.text)
            Text("Go back to create a new meal plan.")
                .font(AppFonts.subheadline())
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(AuthViewModel())
}
