//
//  Logger.swift
//  Makuli
//
//  Created by Ian on 2025-06-30.
//

import Foundation

struct Logger {
    static let isDebugMode = true
    
    // MARK: - Debug Logging (only in debug mode)
    static func debug(_ message: String) {
        #if DEBUG
        if isDebugMode {
            print("🐛 \(message)")
        }
        #endif
    }
    
    static func info(_ message: String) {
        #if DEBUG
        if isDebugMode {
            print("ℹ️ \(message)")
        }
        #endif
    }
    
    static func success(_ message: String) {
        #if DEBUG
        if isDebugMode {
            print("✅ \(message)")
        }
        #endif
    }
    
    // MARK: - Production Logging (always shown, but sanitized)
    static func error(_ message: String, error: Error? = nil) {
        let sanitizedMessage = sanitizeMessage(message)
        print("❌ \(sanitizedMessage)")
        if let error = error {
            print("   Error: \(error.localizedDescription)")
        }
    }
    
    static func warning(_ message: String) {
        let sanitizedMessage = sanitizeMessage(message)
        print("⚠️ \(sanitizedMessage)")
    }
    
    // MARK: - Critical Events (always logged but sanitized)
    static func authEvent(_ event: String) {
        let sanitizedMessage = sanitizeMessage(event)
        print("🔐 Auth: \(sanitizedMessage)")
    }
    
    // MARK: - Helper Methods
    private static func sanitizeMessage(_ message: String) -> String {
        return message
            .replacingOccurrences(of: #"[\w\.-]+@[\w\.-]+\.\w+"#, with: "[EMAIL]", options: .regularExpression)
            .replacingOccurrences(of: #"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"#, with: "[UUID]", options: .regularExpression)
    }
}

// MARK: - Build Configuration
extension Logger {
    static func configureForProduction() {
    }
} 