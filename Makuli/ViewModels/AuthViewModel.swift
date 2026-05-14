//
//  AuthViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-06-30.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager = AuthManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        authManager.$user.assign(to: &$user)
        authManager.$isLoading.assign(to: &$isLoading)
        authManager.$errorMessage.assign(to: &$errorMessage)
    }
    
    func signUp(email: String, password: String) async {
        await authManager.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async {
        await authManager.signIn(email: email, password: password)
    }
    
    func signInWithGoogle() async {
        await authManager.signInWithGoogle()
    }
    
    func signOut() async {
        await authManager.signOut()
    }
    
    func completeOnboarding(age: Int, gender: String, diet: String, budget: String, goal: String) async {
        await authManager.completeOnboarding(age: age, gender: gender, diet: diet, budget: budget, goal: goal)
    }
}

