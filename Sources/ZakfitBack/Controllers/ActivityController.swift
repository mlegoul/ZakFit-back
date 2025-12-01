//
//  ActivityController.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 28/11/2025.
//

import Vapor

struct ActivityController: RouteCollection {
    let activityService: ActivityService
    
    init(activityService: ActivityService = ActivityService()) {
        self.activityService = activityService
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let activitiesRoute = routes.grouped("activities")
        let protectedRoutes = activitiesRoute.grouped(AuthMiddleware())
        
        protectedRoutes.post(use: createActivity)
        protectedRoutes.get(use: getAllActivities)
    }
    
    func createActivity(req: Request) async throws -> Activity {
        let userId = try req.auth.require(User.self).id!
        let activityData = try req.content.decode(CreateActivityDTO.self)
        return try await activityService.createActivity(userId: userId, activityData: activityData, on: req.db)
    }

    func getAllActivities(req: Request) async throws -> [ActivityResponseDTO] {
        let userId = try req.auth.require(User.self).id!
        let typeFilter: String? = req.query["type"]
        
        let activities = try await activityService.getAllActivities(
            userId: userId,
            on: req.db,
            type: typeFilter
        )
        
        return activities.map { activity in
            ActivityResponseDTO(
                type: activity.type,
                duration: activity.duration,
                calories: activity.calories,
                date: activity.date ?? Date()
            )
        }
    }
}
