//
//  PlansView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import SwiftUI

struct PlansView: View {
    @StateObject var viewModel = PlanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var showingPlanCreation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let errorMessage = viewModel.errorMessage {
                            errorView(errorMessage)
                        } else if viewModel.plans.isEmpty && !viewModel.isLoading {
                            emptyStateView
                        } else {
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
            .sheet(isPresented: $showingPlanCreation) {
                PlanCreationView(onPlanCreated: {
                    Task {
                        if let user = authViewModel.user {
                            await viewModel.fetchPlans(for: user.id)
                        }
                    }
                })
                .environmentObject(authViewModel)
            }
        }
    }
}

// MARK: - Error View

extension PlansView {
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.warnRed)

            Text("Something went wrong")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.text)

            Text(message)
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    if let user = authViewModel.user {
                        await viewModel.fetchPlans(for: user.id)
                    }
                }
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primaryOrange)
            .cornerRadius(14)
        }
        .padding()
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 72, weight: .ultraLight))
                    .foregroundColor(AppColors.primaryOrange.opacity(0.6))
                    .padding(.top, 48)

                VStack(spacing: 10) {
                    Text("Plan Your Week")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)

                    Text("Create a meal plan from a template and start eating better this week.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }

            VStack(spacing: 12) {
                Text("What you get")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 36)

                featureCard(icon: "fork.knife.circle", title: "Daily Meals",
                            description: "Breakfast, lunch, and dinner planned for every day")
                featureCard(icon: "chart.bar.fill", title: "Track Progress",
                            description: "Mark meals complete and see your weekly streak")
                featureCard(icon: "cart.fill", title: "Grocery List",
                            description: "Auto-generate a shopping list from your plan")
            }
            .padding(.horizontal, 4)

            Button(action: { showingPlanCreation = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create Your First Plan")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppColors.primaryOrange)
                .cornerRadius(16)
                .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 32)
            .padding(.horizontal, 4)
            .padding(.bottom, 40)
        }
    }

    private func featureCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(AppColors.primaryOrange)
                .frame(width: 44, height: 44)
                .background(AppColors.primaryOrange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.text)
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }

    // MARK: - Existing Plans View

    private var existingPlansView: some View {
        VStack(spacing: 0) {
            headerSection
            newPlanButton
            planContent
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Meal Plan")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)

                if let plan = currentDisplayPlan {
                    Text(formatDateRange(for: plan.plan))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    private var newPlanButton: some View {
        Button(action: { showingPlanCreation = true }) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("New Plan")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primaryOrange)
            .cornerRadius(14)
            .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 24)
    }

    private var planContent: some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryOrange))
                    Text("Loading your plans…")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else if let plan = currentDisplayPlan {
                mealPlanContent(plan)
            } else {
                emptyActivePlanState
            }
        }
    }

    private var currentDisplayPlan: PlanWithRecipes? {
        viewModel.activePlan ?? viewModel.selectedPlan ?? viewModel.plans.first
    }

    // MARK: - Plan Content

    private func mealPlanContent(_ plan: PlanWithRecipes) -> some View {
        VStack(spacing: 24) {
            weekOverviewCard(plan)
            ForEach(getDayMeals(for: plan), id: \.dayOfWeek) { dayMeals in
                dayMealSection(dayMeals)
            }
        }
    }

    private func weekOverviewCard(_ plan: PlanWithRecipes) -> some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week Overview")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    Text("\(plan.mealCount) meals · \(plan.completedMealCount) completed")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(plan.completionPercentage))%")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryOrange)
                    Text("complete")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            ProgressView(value: plan.completionPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                .scaleEffect(y: 2.5)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(AppColors.primaryOrange.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Day Section

    private func dayMealSection(_ dayMeals: PlanDayMeals) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: dayIcon(dayMeals.dayOfWeek))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryOrange)
                Text(formatDayHeader(dayMeals.day, dayOfWeek: dayMeals.dayOfWeek))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                Spacer()
            }

            let meals = dayMeals.breakfast + dayMeals.lunch + dayMeals.dinner + dayMeals.snacks
            if meals.isEmpty {
                emptyDayRow
            } else {
                VStack(spacing: 10) {
                    ForEach(dayMeals.breakfast, id: \.id) { mealEntry($0, mealType: "Breakfast") }
                    ForEach(dayMeals.lunch,     id: \.id) { mealEntry($0, mealType: "Lunch")    }
                    ForEach(dayMeals.dinner,    id: \.id) { mealEntry($0, mealType: "Dinner")   }
                    ForEach(dayMeals.snacks,    id: \.id) { mealEntry($0, mealType: "Snack")    }
                }
            }
        }
    }

    private var emptyDayRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(AppColors.textSecondary)
            Text("No meals planned")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppColors.border, lineWidth: 1)
                )
        )
    }

    private func mealEntry(_ recipe: PlanRecipe, mealType: String) -> some View {
        let imageURLString = recipe.imageUrl
            ?? ProductionSeeder.mealImageURL(for: recipe.customMealName ?? "")
        let imageURL = imageURLString.flatMap { URL(string: $0) }

        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(mealTypeColor(mealType).opacity(0.12))

                if let url = imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .aspectRatio(contentMode: .fill)
                                .transition(.opacity.animation(.easeIn(duration: 0.25)))
                        case .failure:
                            mealIconFallback(mealType: mealType)
                        case .empty:
                            MealImageShimmer()
                        @unknown default:
                            mealIconFallback(mealType: mealType)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    mealIconFallback(mealType: mealType)
                }
            }
            .frame(width: 68, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 0.5)
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(mealType.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(mealTypeColor(mealType))
                    .tracking(0.6)

                Text(recipe.customMealName ?? "Meal")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let cookTime = recipe.customCookTime, cookTime > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(cookTime) min")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer(minLength: 4)

            ZStack {
                Circle()
                    .fill(recipe.isCompleted
                          ? AppColors.successGreen.opacity(0.15)
                          : Color.clear)
                    .frame(width: 36, height: 36)
                Image(systemName: recipe.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(recipe.isCompleted ? AppColors.successGreen : AppColors.border)
                    .symbolEffect(.bounce, value: recipe.isCompleted)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    recipe.isCompleted ? AppColors.successGreen.opacity(0.25) : Color.clear,
                    lineWidth: 1
                )
        )
        .opacity(recipe.isCompleted ? 0.78 : 1.0)
    }

    @ViewBuilder
    private func mealIconFallback(mealType: String) -> some View {
        Image(systemName: mealTypeIcon(mealType))
            .font(.system(size: 22, weight: .light))
            .foregroundColor(mealTypeColor(mealType).opacity(0.7))
    }

    private func mealTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "breakfast": return "cup.and.saucer.fill"
        case "lunch":     return "fork.knife"
        case "dinner":    return "moon.stars.fill"
        default:          return "leaf.fill"
        }
    }

    private var emptyActivePlanState: some View {
        VStack(spacing: 28) {
            Image(systemName: "calendar")
                .font(.system(size: 60, weight: .ultraLight))
                .foregroundColor(AppColors.primaryOrange.opacity(0.5))
                .padding(.top, 48)

            VStack(spacing: 10) {
                Text("No Active Plan")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                Text("Create a plan to see your meals here")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }

            Button(action: { showingPlanCreation = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create a Plan")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppColors.primaryOrange)
                .cornerRadius(14)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Helpers

    private func dayIcon(_ dayOfWeek: Int) -> String {
        switch dayOfWeek {
        case 0: return "sun.horizon"
        case 1: return "1.circle"
        case 2: return "2.circle"
        case 3: return "3.circle"
        case 4: return "4.circle"
        case 5: return "5.circle"
        case 6: return "sparkles"
        default: return "calendar"
        }
    }

    private func mealTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "breakfast": return Color.orange
        case "lunch":     return Color.teal
        case "dinner":    return Color.indigo
        default:          return Color.gray
        }
    }

    private func formatDateRange(for plan: Plan) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: plan.weekStart)) – \(f.string(from: plan.weekEnd))"
    }

    private func formatDayHeader(_ day: String, dayOfWeek: Int) -> String {
        let today = Calendar.current.component(.weekday, from: Date()) - 1
        if dayOfWeek == today { return "Today" }
        if dayOfWeek == (today + 1) % 7 { return "Tomorrow" }
        return day
    }

    private func getDayMeals(for plan: PlanWithRecipes) -> [PlanDayMeals] {
        viewModel.getDayMeals(for: plan)
    }
}

// MARK: - Meal Image Shimmer

private struct MealImageShimmer: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [
                    Color(.systemGray5),
                    Color(.systemGray4).opacity(0.6),
                    Color(.systemGray5)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 3)
            .offset(x: geo.size.width * phase)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        }
        .clipped()
    }
}

#Preview {
    PlansView()
        .environmentObject(AuthViewModel())
}
