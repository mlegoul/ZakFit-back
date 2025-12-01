//
//  ActivityService.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 28/11/2025.
//

import Vapor
import Fluent

struct ActivityService {
    let activityRepository: any ActivityRepositoryProtocol
    
    init(
        activityRepository: any ActivityRepositoryProtocol = ActivityRepository()
    ) {
        self.activityRepository = activityRepository
    }
    
    func createActivity(userId: UUID, activityData: CreateActivityDTO, on db: any Database) async throws -> Activity {
        let activity = Activity(
            userId: userId,
            type: activityData.type,
            duration: activityData.duration,
            calories: activityData.calories,
            date: activityData.date ?? Date()
        )

        return try await activityRepository.create(activity: activity, on: db)
    }
    
    func getAllActivities(userId: UUID, on db: any Database, filter: ActivityFilterDTO) async throws -> [Activity] {
        return try await activityRepository.getAllActivities(
            userId: userId,
            on: db,
            filter: filter
        )
    }
}
