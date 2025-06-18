//
//  ContentView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Karibu Makuli!")
                .font(AppFonts.title2())
                .foregroundStyle(AppColors.textCharcoal)
            
            Button("Start Planning") { }
                .primaryButtonStyle()
        }
        .padding()
        .background(AppColors.bgCream)
    }
}
#Preview {
    ContentView()
}
