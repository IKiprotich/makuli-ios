import Foundation

/// Logger utility for debug and production logging throughout the app.
struct Logger {
    // Set to false for production builds
    static let isDebugMode = true
    
    // MARK: - Debug Logging (only in debug mode)
    /// Prints debug messages in debug mode only.
    static func debug(_ message: String) {
        #if DEBUG
        if isDebugMode {
            print("🐛 \(message)")
        }
        #endif
    }
    
    /// Prints informational messages in debug mode only.
    static func info(_ message: String) {
        #if DEBUG
        if isDebugMode {
            print("ℹ️ \(message)")
        }
        #endif
    }
    
    /// Prints success messages in debug mode only.
    static func success(_ message: String) {
        #if DEBUG
        if isDebugMode {
            print("✅ \(message)")
        }
        #endif
    }
    
    // MARK: - Production Logging (always shown, but sanitized)
    /// Prints error messages (always shown, sanitized for production).
    static func error(_ message: String, error: Error? = nil) {
        let sanitizedMessage = sanitizeMessage(message)
        print("❌ \(sanitizedMessage)")
        if let error = error {
            print("   Error: \(error.localizedDescription)")
        }
    }
    
    /// Prints warning messages (always shown, sanitized for production).
    static func warning(_ message: String) {
        let sanitizedMessage = sanitizeMessage(message)
        print("⚠️ \(sanitizedMessage)")
    }
    
    // MARK: - Critical Events (always logged but sanitized)
    /// Prints authentication-related events (always shown, sanitized for production).
    static func authEvent(_ event: String) {
        let sanitizedMessage = sanitizeMessage(event)
        print("🔐 Auth: \(sanitizedMessage)")
    }
    
    // MARK: - Helper Methods
    /// Helper to sanitize log messages (removes sensitive data).
    private static func sanitizeMessage(_ message: String) -> String {
        // Remove sensitive data from production logs
        return message
            .replacingOccurrences(of: #"[\w\.-]+@[\w\.-]+\.\w+"#, with: "[EMAIL]", options: .regularExpression)
            .replacingOccurrences(of: #"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"#, with: "[UUID]", options: .regularExpression)
    }
}

// MARK: - Build Configuration
extension Logger {
    /// Configures the logger for production (e.g., disables debug logging, sets up external logging services).
    static func configureForProduction() {
        // In production, you might want to use a proper logging framework
        // like OSLog or send logs to a service like Sentry
    }
} 