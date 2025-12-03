//
//  ActivitySummaryController.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 02/12/2025.
//

import Fluent
import Vapor

struct ActivitySummaryController: RouteCollection {
    let service: ActivitySummaryService
    
    init(service: ActivitySummaryService = ActivitySummaryService()) {
        self.service = service
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let activitiesRoute = routes.grouped("api", "users", ":userId")
        let protectedRoutes = activitiesRoute.grouped(AuthMiddleware())
        protectedRoutes.get("daily-activity-summary", use: dailyActivitySummary)
    }
    
    func dailyActivitySummary(_ req: Request) async throws -> DailyActivitySummaryResponse {
        
        guard let userIdString = req.parameters.get("userId") else {
            print("Debug: Invalid user ID parameter")
            throw Abort(.badRequest, reason: "Invalid user ID parameter")
        }
        
        guard let userId = UUID(uuidString: userIdString) else {
            print("Debug: Invalid user ID format")
            throw Abort(.badRequest, reason: "Invalid user ID format")
        }
                
        let dateString = req.query["date"] ?? ISO8601DateFormatter().string(
            from: Date()
        )
        
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            print("Debug: Invalid date format")
            throw Abort(
                .badRequest,
                reason: "Invalid date format. Expected ISO8601 format."
            )
        }
        
        let result = try await service.getDailyActivitySummary(
            for: userId,
            on: date,
            db: req.db
        )
        
        return DailyActivitySummaryResponse(
            userId: result.userId,
            date: result.date,
            type: result.type,
            totalDuration: result.totalDuration,
            totalCalories: result.totalCalories,
            message: result.totalDuration == 0 && result.totalCalories == 0 ? "No activities found for this date." : nil
        )
    }
}
