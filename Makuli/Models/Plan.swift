//
//  Plan.swift
//  Makuli
//
//  Created by on 2025-07-03.
//
//  Maps to the Supabase 'plans' table. Represents a meal plan record.
//
import Foundation

struct Plan: Codable, Identifiable {
    let id: String
    let user_id: String
    let title: String
    let created_at: String?
    let week_start: String?
} 