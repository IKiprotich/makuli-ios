//
//  AuthHeaderView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI

struct AuthHeaderView: View {
    let isSignUp: Bool
    
    var body: some View {
        VStack {
            Text("Makuli")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(isSignUp ? "Create your account" : "Welcome back")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 50)
    }
}

// MARK: - Preview
struct AuthHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AuthHeaderView(isSignUp: false)
            AuthHeaderView(isSignUp: true)
        }
        .padding()
    }
} 