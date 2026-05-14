//
//  AuthDividerView.swift
//  Makuli
//
//  Created by Ian on 2025-06-27.
//

import SwiftUI

struct AuthDividerView: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary)
            
            Text("or")
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct AuthDividerView_Previews: PreviewProvider {
    static var previews: some View {
        AuthDividerView()
            .padding()
    }
} 