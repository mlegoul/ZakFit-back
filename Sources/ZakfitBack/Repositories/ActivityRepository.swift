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
    
    func getAllActivities(userId: UUID, on db: any Database, type: String?) async throws -> [Activity]
}

struct ActivityRepository: ActivityRepositoryProtocol {
    
    func create(activity: Activity, on db: any Database) async throws -> Activity {
        try await activity.save(on: db)
        return activity
    }
    
    func getAllActivities(userId: UUID, on db: any Database, type: String?) async throws -> [Activity] {
        var query = Activity.query(on: db)
        query = query.filter(\.$user.$id == userId)
        
        if let type = type {
            query = query.filter(\.$type == type)
        }
        
        return try await query.all()
    }
}
