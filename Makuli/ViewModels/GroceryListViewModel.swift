import Foundation
import Supabase

@MainActor
class GroceryListViewModel: ObservableObject {
    @Published var groceries: [GroceryItem] = []

    func fetchGroceries(for userId: String) async {
        do {
            let response = try await SupabaseManager.shared.client
                .from("grocery_list")
                .select()
                .eq("user_id", value: userId)
                .execute()
            let groceries = try JSONDecoder().decode([GroceryItem].self, from: response.data)
            self.groceries = groceries
        } catch {
            print("Error fetching groceries: \(error.localizedDescription)")
            self.groceries = []
        }
    }
} 