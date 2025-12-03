//
//  ActivitySummaryRepository.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 02/12/2025.
//

import Fluent
import Vapor
import FluentSQL

protocol ActivitySummaryRepositoryProtocol: Sendable {
    func getDailyActivitySummary(for userId: UUID, on date: Date, db: any Database) async throws -> DailyActivitySummary
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }
}

struct ActivitySummaryRepository: ActivitySummaryRepositoryProtocol, Sendable {
    func getDailyActivitySummary(for userId: UUID, on date: Date, db: any Database) async throws -> DailyActivitySummary {
        
        if let sql = db as? (any SQLDatabase) {
            let rows = try await sql.raw("SELECT type, duration, calories FROM activity WHERE user_id = \(bind: userId) AND date >= \(bind: date.startOfDay) AND date < \(bind: date.endOfDay)").all()
            
            let activities = try rows.map { row in
                let type = try row.decode(column: "type", as: String.self)
                let duration = try row.decode(column: "duration", as: Int.self)
                let calories = try row.decode(column: "calories", as: Int.self)
                return (type: type, duration: duration, calories: calories)
            }
            
            let totalDuration = activities.reduce(0) { $0 + $1.duration }
            let totalCalories = activities.reduce(0) { $0 + $1.calories }
            let type = activities.isEmpty ? "No activities" : activities[0].type
            
            return DailyActivitySummary(
                userId: userId,
                date: date,
                type: type,
                totalDuration: totalDuration,
                totalCalories: totalCalories
            )
        } else {
            throw Abort(
                .internalServerError,
                reason: "Database is not SQLDatabase"
            )
        }
    }
}
