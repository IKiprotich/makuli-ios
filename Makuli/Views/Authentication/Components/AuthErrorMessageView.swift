//
//  AuthErrorMessageView.swift
//  Makuli
//
//  Created by Ian on 2025-06-27.
//

import SwiftUI

struct AuthErrorMessageView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.1))
            )
            .padding(.horizontal)
    }
}

// MARK: - Preview
struct AuthErrorMessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AuthErrorMessageView(message: "Invalid email or password")
            AuthErrorMessageView(message: "Network error. Please check your connection and try again.")
        }
        .padding()
    }
} 