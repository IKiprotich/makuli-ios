//
//  PlanCreationView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import SwiftUI

struct PlanCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var planViewModel = PlanViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    @State private var selectedTemplate: MealPlanTemplate?
    @State private var weekStartDate = Date()
    @State private var isCreating = false

    var onPlanCreated: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        templateSection
                        weekPickerSection
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }

                VStack {
                    Spacer()
                    createButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
            }
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.primaryOrange)
                }
            }
            .task {
                if let user = authViewModel.user {
                    async let _ = profileViewModel.fetchProfile(for: user.id)
                    async let _ = planViewModel.fetchTemplates()
                }
            }
            .alert("Error", isPresented: Binding(
                get: { planViewModel.errorMessage != nil },
                set: { if !$0 { planViewModel.clearError() } }
            )) {
                Button("OK") { planViewModel.clearError() }
            } message: {
                Text(planViewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Template Section

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                icon: "doc.text.fill",
                title: "Choose a Template",
                subtitle: "Pick a curated weekly plan to get started"
            )

            if planViewModel.isLoadingTemplates {
                loadingTemplatesView
            } else if planViewModel.templates.isEmpty {
                emptyTemplatesView
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(planViewModel.templates, id: \.id) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplate?.id == template.id
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTemplate = template
                            }
                        }
                    }
                }
            }
        }
    }

    private var loadingTemplatesView: some View {
        HStack(spacing: 10) {
            ProgressView().scaleEffect(0.85)
            Text("Loading templates…")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private var emptyTemplatesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(AppColors.textSecondary)
            Text("No templates yet")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.text)
            Text("Use the Developer Panel to seed templates")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Week Picker Section

    private var weekPickerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                icon: "calendar",
                title: "Week Starting",
                subtitle: "Plans run Monday to Sunday"
            )

            HStack {
                DatePicker(
                    "",
                    selection: $weekStartDate,
                    in: mondayOfCurrentWeek...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.card)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
    }

    // MARK: - Create Button

    private var createButton: some View {
        Button(action: createPlan) {
            HStack(spacing: 10) {
                if isCreating {
                    ProgressView()
                        .scaleEffect(0.85)
                        .tint(.white)
                } else {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(isCreating ? "Creating…" : "Create Plan")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(canCreate ? AppColors.primaryOrange : Color.gray.opacity(0.4))
            )
            .shadow(color: canCreate ? AppColors.primaryOrange.opacity(0.35) : .clear,
                    radius: 10, x: 0, y: 5)
        }
        .disabled(!canCreate || isCreating)
        .animation(.easeInOut(duration: 0.2), value: canCreate)
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryOrange)
                .frame(width: 32, height: 32)
                .background(AppColors.primaryOrange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private var canCreate: Bool {
        selectedTemplate != nil && authViewModel.user != nil
    }

    private var mondayOfCurrentWeek: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let daysToMonday = (weekday == 1) ? 0 : (2 - weekday + 7) % 7
        return cal.date(byAdding: .day, value: -daysToMonday, to: today) ?? today
    }

    private func createPlan() {
        guard let user = authViewModel.user,
              let template = selectedTemplate else { return }

        isCreating = true
        Task {
            let profile = profileViewModel.profile
            let success: Bool
            if let profile {
                success = await planViewModel.createPlanFromTemplate(
                    templateId: template.id,
                    for: user.id,
                    weekStart: weekStartDate,
                    userProfile: profile
                )
            } else {
                success = await planViewModel.createPlanDirectly(
                    templateId: template.id,
                    for: user.id,
                    weekStart: weekStartDate,
                    title: template.name
                )
            }
            isCreating = false
            if success {
                if profile != nil {
                    await profileViewModel.incrementPlanCreationCount()
                }
                onPlanCreated?()
                dismiss()
            }
        }
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: MealPlanTemplate
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(template.icon ?? "🍽️")
                        .font(.system(size: 28))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primaryOrange)
                    }
                }

                Text(template.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let desc = template.description {
                    Text(desc)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Text(template.cookingSkillLevel.capitalized)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryOrange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.primaryOrange.opacity(0.12), in: Capsule())
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.card)
                    .shadow(color: .black.opacity(isSelected ? 0.08 : 0.04), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? AppColors.primaryOrange : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlanCreationView()
        .environmentObject(AuthViewModel())
}
