//
//  AuthToggleView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI

struct AuthToggleView: View {
    @Binding var isSignUp: Bool
    let authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: {
            isSignUp.toggle()
            authViewModel.errorMessage = nil
        }) {
            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                .font(.footnote)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Preview
struct AuthToggleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AuthToggleView(isSignUp: .constant(false), authViewModel: AuthViewModel())
            AuthToggleView(isSignUp: .constant(true), authViewModel: AuthViewModel())
        }
        .padding()
    }
} 