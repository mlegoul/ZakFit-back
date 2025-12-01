//
//  ActivityRepository.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 28/11/2025.
//

import Vapor
import Fluent

protocol ActivityRepositoryProtocol: Sendable {
    func create(activity: Activity, on db: any Database) async throws -> Activity
    
    func getAllActivities(userId: UUID, on db: any Database, type: String?, startDate: String?, endDate: String?) async throws -> [Activity]
}

struct ActivityRepository: ActivityRepositoryProtocol {
    
    func create(activity: Activity, on db: any Database) async throws -> Activity {
        try await activity.save(on: db)
        return activity
    }
    
    
    func getAllActivities(userId: UUID, on db: any Database, type: String?, startDate: String?, endDate: String?) async throws -> [Activity] {
        var query = Activity.query(on: db)
        query = query.filter(\.$user.$id == userId)
        
        if let type = type {
            query = query.filter(\.$type == type)
        }
        
        if let startDate = startDate, let endDate = endDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let start = dateFormatter.date(from: startDate),
                  let end = dateFormatter.date(from: endDate) else {
                throw Abort(
                    .badRequest,
                    reason: "Invalid date format. Use yyyy-MM-dd"
                )
            }
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: start)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: end)!
            query = query
                .filter(\.$date >= startOfDay)
                .filter(\.$date < endOfDay)
        }
        
        return try await query.all()
    }
}
