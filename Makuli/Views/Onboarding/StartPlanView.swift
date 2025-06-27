//
//  StartPlanView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import SwiftUI

// Profile data struct for Supabase
struct ProfileUpdateData: Encodable {
    let age: Int
    let gender: String
    let diet: String
    let budget: String
    let updated_at: String
}

struct StartPlanView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            AppColors.bgCream
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress indicator
                ProgressView(value: 7, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primaryOrange)
                
                VStack(spacing: 20) {
                    Text("You're all set!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personalized meal plan is ready")
                        .font(.title3)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Summary card
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Profile")
                        .font(.headline)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Group {
                        HStack {
                            Text("Age:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(onboardingData.age) years")
                        }
                        HStack {
                            Text("Gender:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(onboardingData.gender)
                        }
                        HStack {
                            Text("Goal:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(onboardingData.goal)
                        }
                        HStack {
                            Text("Budget:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(onboardingData.budget)
                        }
                    }
                    .foregroundColor(AppColors.textCharcoal)
                    
                    if !onboardingData.dietPreferences.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Diet Preferences:")
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textCharcoal)
                            
                            Text(onboardingData.dietPreferences.joined(separator: ", "))
                                .foregroundColor(AppColors.textCharcoal.opacity(0.8))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    // Save onboarding data to user profile
                    Task {
                        await saveOnboardingData()
                    }
                    
                    // Mark onboarding as completed
                    hasCompletedOnboarding = true
                    
                    // Notify that onboarding is completed
                    NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                }) {
                    Text("Start My Meal Plan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primaryOrange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func saveOnboardingData() async {
        guard let user = authManager.user else { return }
        
        do {
            let profileData = ProfileUpdateData(
                age: onboardingData.age,
                gender: onboardingData.gender,
                diet: onboardingData.dietPreferences.joined(separator: ", "),
                budget: onboardingData.budget,
                updated_at: ISO8601DateFormatter().string(from: Date())
            )
            
            try await SupabaseManager.shared.client
                .from("profiles")
                .update(profileData)
                .eq("id", value: user.email) 
                .execute()
        } catch {
            print("Error saving onboarding data: \(error)")
        }
    }
}

#Preview {
    let data = OnboardingData()
    data.age = 25
    data.gender = "Female"
    data.goal = "Lose Weight"
    data.budget = "$100 - $200"
    data.dietPreferences = ["Vegetarian", "Gluten-free"]
    
    return StartPlanView(
        onboardingData: data,
        hasCompletedOnboarding: .constant(false)
    )
    .environmentObject(AuthManager())
}
