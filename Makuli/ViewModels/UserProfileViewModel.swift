import Supabase
import SwiftUI

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var error: String?
    @Published var uploadSuccess: Bool = false
    @Published var uploadError: String? = nil
    
    private var fetchTask: Task<Void, Never>?
    
    // Notification name for profile updates
    static let profileUpdatedNotification = Notification.Name("ProfileUpdated")

    func fetchProfile() async {
        // Don't fetch if we already have a profile and no error
        if profile != nil && error == nil {
            print("[DEBUG] Profile already loaded, skipping fetch")
            return
        }
        
        // Cancel any existing fetch task to prevent duplicate requests
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch()
        }
        
        await fetchTask?.value
    }
    
    func forceRefreshProfile() async {
        // Clear current data and force fetch
        profile = nil
        error = nil
        await fetchProfile()
    }
    
    // Method to notify other views that profile has been updated
    func notifyProfileUpdated() {
        NotificationCenter.default.post(name: Self.profileUpdatedNotification, object: nil)
    }
    
    // Method to listen for profile updates
    func startListeningForUpdates() {
        NotificationCenter.default.addObserver(
            forName: Self.profileUpdatedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.forceRefreshProfile()
            }
        }
    }
    
    // Method to stop listening for updates
    nonisolated func stopListeningForUpdates() {
        NotificationCenter.default.removeObserver(self, name: Self.profileUpdatedNotification, object: nil)
    }
    
    private func performFetch() async {
        guard let user = try? await SupabaseManager.shared.client.auth.session.user else {
            self.error = "No user session found."
            print("[DEBUG] No user session found.")
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            // Use consistent ID format (lowercase) as in AuthManager
            let userId = user.id.uuidString.lowercased()
            
            let response: [UserProfile] = try await SupabaseManager.shared.client
                .from("profiles")
                .select("*")
                .eq("id", value: userId)
                .execute()
                .value
            
            print("[DEBUG] Supabase response for user id: \(userId)")
            print("[DEBUG] Found \(response.count) profiles")
            
            if let profile = response.first {
                self.profile = profile
                self.error = nil
                print("[DEBUG] Successfully loaded UserProfile: \(profile.name ?? "No Name")")
            } else {
                self.error = "No profile found for this user. Please complete onboarding."
                self.profile = nil
                print("[DEBUG] No profile found for user id: \(userId)")
            }
        } catch {
            self.error = "Failed to fetch profile: \(error.localizedDescription)"
            self.profile = nil
            print("[DEBUG] Fetch error: \(error)")
        }
    }
    
    @MainActor
    func uploadProfileImage(data: Data) async {
        guard let userId = profile?.id else { return }
        do {
            let imageUrl = try await SupabaseManager.shared.uploadProfileImage(userId: userId, imageData: data)
            profile?.profileImageUrl = imageUrl
            try await SupabaseManager.shared.updateUserProfileImageUrl(userId: userId, imageUrl: imageUrl)
            
            // Force refresh the profile data to ensure all views get the updated image URL
            await forceRefreshProfile()
            
            // Notify other views that profile has been updated
            notifyProfileUpdated()
            
            uploadSuccess = true
            uploadError = nil
        } catch {
            print("Failed to upload image: \(error)")
            uploadSuccess = false
            uploadError = error.localizedDescription
        }
    }
    
    deinit {
        fetchTask?.cancel()
        stopListeningForUpdates()
    }
} 