//
//  View+Extensions.swift
//  Makuli
//
//  Created by Ian on 2025-06-27.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 