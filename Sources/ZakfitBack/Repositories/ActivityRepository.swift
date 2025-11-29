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
    
    func getAllActivities(userId: UUID, on db: any Database) async throws -> [Activity]
}

struct ActivityRepository: ActivityRepositoryProtocol {
    
    func create(activity: Activity, on db: any Database) async throws -> Activity {
        try await activity.save(on: db)
        return activity
    }
    
    func getAllActivities(userId: UUID, on db: any Database) async throws -> [Activity] {
        return try await Activity.query(on: db)
            .filter(\.$user.$id == userId)
            .all()
    }
}
