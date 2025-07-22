//
//  DeveloperPanelView.swift
//  Makuli
//
//  Created by AI Assistant on 2025-01-13.
//
//  Developer panel for database seeding and admin functions.
//

import SwiftUI

struct DeveloperPanelView: View {
    @StateObject private var seeder = DatabaseSeeder.shared
    @StateObject private var templateService = TemplateService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateCount = 0
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    databaseStatusSection
                    
                    actionsSection
                    
                    if seeder.isSeeding {
                        seedingProgressSection
                    }
                    
                    if let successMessage = seeder.successMessage {
                        successSection(successMessage)
                    }
                    
                    if let errorMessage = seeder.errorMessage {
                        errorSection(errorMessage)
                    }
                    
                    templatesPreviewSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Developer Panel")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
            .task {
                await refreshTemplateCount()
            }
            .refreshable {
                await refreshTemplateCount()
            }
            .alert("Seed Database", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Seed Templates") {
                    Task {
                        await seeder.seedDatabase()
                        await refreshTemplateCount()
                    }
                }
            } message: {
                Text("This will add \(getExpectedTemplateCount()) meal plan templates to your Supabase database. Continue?")
            }
        }
    }
}

extension DeveloperPanelView {
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "hammer.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryOrange)
                
                Text("Developer Tools")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text("Use this panel to seed your Supabase database with meal plan templates")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var databaseStatusSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Database Status")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Templates")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(templateCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(templateCount > 0 ? AppColors.primaryOrange : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Available Categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(TemplateCategory.allCases.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Actions")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                Button {
                    showingConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Seed Templates (\(getExpectedTemplateCount()) total)")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryOrange)
                    .cornerRadius(10)
                }
                .disabled(seeder.isSeeding)
                
                Button {
                    Task {
                        await refreshTemplateCount()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Count")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.primaryOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.primaryOrange.opacity(0.1))
                    .cornerRadius(8)
                }
                .disabled(seeder.isSeeding)
            }
        }
    }
    
    private var seedingProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Seeding Database...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(seeder.seedingProgress)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func successSection(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Success")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func errorSection(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Error")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var templatesPreviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Template Categories")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(TemplateCategory.allCases, id: \.self) { category in
                    VStack(spacing: 8) {
                        Text("🍽️")
                            .font(.title2)
                        
                        Text(category.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        Text("Template category")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func refreshTemplateCount() async {
        templateCount = await seeder.checkTemplateCount()
    }
    
    private func getExpectedTemplateCount() -> Int {
        return 14 // Based on the number of templates in createSampleTemplates()
    }
}

#Preview {
    DeveloperPanelView()
} 