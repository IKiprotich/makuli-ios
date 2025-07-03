//
//  ProfileViewModel.swift
//  Makuli
//
//  Created by on 2025-07-03.
//
//  Handles fetching and managing user profile data from Supabase.
//
import Foundation
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?

    func fetchProfile(userId: String) async {
        do {
            let response = try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .select("*")
                .eq("id", value: userId)
                .execute()
            let profile = try JSONDecoder().decode([UserProfile].self, from: response.data).first
            self.profile = profile
        } catch {
            print("Failed to fetch user profile: \(error.localizedDescription)")
        }
    }
} 