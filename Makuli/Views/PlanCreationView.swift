//
//  PlanCreationView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready plan creation view with templates and AI generation.
//

import SwiftUI

struct PlanCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var planViewModel = PlanViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedCreationMethod: CreationMethod = .template
    @State private var selectedTemplate: MealPlanTemplate?
    @State private var weekStartDate = Date()
    @State private var showingAIGeneration = false
    @State private var isCreating = false
    
    enum CreationMethod: String, CaseIterable {
        case template = "Template"
        case ai = "AI Generate"
        
        var icon: String {
            switch self {
            case .template:
                return "doc.text.fill"
            case .ai:
                return "wand.and.stars"
            }
        }
        
        var description: String {
            switch self {
            case .template:
                return "Choose from our curated meal plan templates"
            case .ai:
                return "Let AI create a personalized meal plan for you"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    creationMethodSelector
                    
                    if selectedCreationMethod == .template {
                        templateSelection
                    } else {
                        aiGenerationSection
                    }
                    
                    weekSelectionSection
                    
                    createPlanButton
                }
                .padding()
            }
            .navigationTitle("Create Meal Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                if let user = authViewModel.user {
                    await profileViewModel.fetchProfile(for: user.id)
                    await planViewModel.fetchTemplates()
                }
            }
            .alert("Error", isPresented: .constant(planViewModel.errorMessage != nil)) {
                Button("OK") {
                    planViewModel.clearError()
                }
            } message: {
                if let errorMessage = planViewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("Success", isPresented: .constant(planViewModel.selectedPlan != nil && !isCreating)) {
                Button("View Plan") {
                    dismiss()
                }
                Button("Create Another") {
                    planViewModel.selectedPlan = nil
                    selectedTemplate = nil
                }
            } message: {
                Text("Your meal plan has been created successfully!")
            }
        }
    }
}

extension PlanCreationView {
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(AppColors.primaryOrange)
            
            Text("Create Your Meal Plan")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Choose how you'd like to create your weekly meal plan")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var creationMethodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Creation Method")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(CreationMethod.allCases, id: \.self) { method in
                    Button(action: {
                        selectedCreationMethod = method
                        selectedTemplate = nil
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: method.icon)
                                .font(.title2)
                                .foregroundColor(selectedCreationMethod == method ? .white : AppColors.primaryOrange)
                            
                            Text(method.rawValue)
                                .font(.headline)
                                .foregroundColor(selectedCreationMethod == method ? .white : .primary)
                            
                            Text(method.description)
                                .font(.caption)
                                .foregroundColor(selectedCreationMethod == method ? .white.opacity(0.8) : .secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedCreationMethod == method ?
                            AppColors.primaryOrange :
                            AppColors.primaryOrange.opacity(0.1)
                        )
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var templateSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Template")
                .font(.headline)
            
            if planViewModel.isLoadingTemplates {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading templates...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if planViewModel.templates.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.badge.ellipsis")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    
                    Text("No templates available")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Please check your connection and try again")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.bgCream)
                .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(planViewModel.templates, id: \.id) { template in
                        SelectableTemplateCard(
                            template: template,
                            isSelected: selectedTemplate?.id == template.id,
                            onSelect: {
                                selectedTemplate = template
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var aiGenerationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Generation")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "wand.and.stars.inverse")
                        .foregroundColor(AppColors.primaryOrange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Personalized Meal Plan")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("AI will create a custom plan based on your profile")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(AppColors.primaryOrange.opacity(0.1))
                .cornerRadius(12)
                
                // Show usage limits if applicable
                if let profile = profileViewModel.profile, !profile.hasPremiumAccess {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        
                        Text("You have \(profile.aiGenerationsRemainingThisMonth) AI generations remaining this month")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var weekSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Week Starting")
                .font(.headline)
            
            DatePicker(
                "Week Start Date",
                selection: $weekStartDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .padding()
            .background(AppColors.bgCream)
            .cornerRadius(12)
        }
    }
    
    private var createPlanButton: some View {
        Button(action: createPlan) {
            HStack {
                if isCreating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: selectedCreationMethod == .template ? "doc.badge.plus" : "wand.and.stars")
                }
                
                Text(isCreating ? "Creating Plan..." : "Create Plan")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canCreatePlan ? AppColors.primaryOrange : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!canCreatePlan || isCreating)
    }
    
    private var canCreatePlan: Bool {
        guard let user = authViewModel.user,
              let profile = profileViewModel.profile else { return false }
        
        switch selectedCreationMethod {
        case .template:
            return selectedTemplate != nil && profile.canCreateMorePlans
        case .ai:
            return profile.canUseAIGeneration && profile.canCreateMorePlans
        }
    }
    
    private func createPlan() {
        guard let user = authViewModel.user,
              let profile = profileViewModel.profile else { return }
        
        isCreating = true
        
        Task {
            var success = false
            
            switch selectedCreationMethod {
            case .template:
                if let template = selectedTemplate {
                    success = await planViewModel.createPlanFromTemplate(
                        templateId: template.id,
                        for: user.id,
                        weekStart: weekStartDate,
                        userProfile: profile
                    )
                    
                    if success {
                        await profileViewModel.incrementPlanCreationCount()
                    }
                }
                
            case .ai:
                let preferences = MealPlanPreferences(
                    weekStartDate: weekStartDate,
                    budget: profile.budget ?? "Medium ($60-100)",
                    dietaryRestrictions: [profile.diet ?? "No restrictions"],
                    goals: [profile.goal ?? "General Health"],
                    excludedIngredients: []
                )
                
                success = await planViewModel.generateAIMealPlan(
                    for: profile,
                    preferences: preferences
                )
                
                if success {
                    await profileViewModel.incrementPlanCreationCount()
                    await profileViewModel.incrementAIGenerationCount()
                }
            }
            
            isCreating = false
            
            if success {
                // Success will be handled by the alert
            }
        }
    }
}

// Removed duplicate TemplateCard declaration - using SelectableTemplateCard instead
struct SelectableTemplateCard: View {
    let template: MealPlanTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(template.icon ?? "🍽️")
                        .font(.title2)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("$\(Int(template.estimatedCostMin))-\(Int(template.estimatedCostMax))")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text(template.difficulty.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.primaryOrange.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? AppColors.primaryOrange.opacity(0.1) : AppColors.bgCream)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primaryOrange : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlanCreationView()
        .environmentObject(AuthViewModel())
} 