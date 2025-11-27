//
//  UserProfileController.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 26/11/2025.
//

import Vapor
import Fluent

struct UserProfileController: RouteCollection {
    
    let userProfileService: UserProfileService
    
    init(userProfileService: UserProfileService = UserProfileService()) {
        self.userProfileService = userProfileService
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        let protectedRoutes = usersRoute.grouped(AuthMiddleware())
        
        protectedRoutes.get("profile", "info", use: getUserInfo)
        protectedRoutes.get("profile", "health", use: getUserHealth)
        protectedRoutes.get("profile", "goals", use: getUserGoals)
        
        protectedRoutes.patch("profile", "goals", use: updateUserGoals)
    }
    
    func getUserInfo(req: Request) async throws -> UserPublic {
        let userId = try req.auth.require(User.self).id!
        guard let userProfile = try await userProfileService.getUserInfo(userId: userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return userProfile
    }
    
    func getUserHealth(req: Request) async throws -> UserHealthDTO {
        let userId = try req.auth.require(User.self).id!
        guard let userHealth = try await userProfileService.getUserHealth(userId: userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return userHealth
    }
    
    func getUserGoals(req: Request) async throws -> UserGoalsDTO {
        let userId = try req.auth.require(User.self).id!
        guard let userGoals = try await userProfileService.getUserGoals(userId: userId, on: req.db) else {
            throw Abort(.notFound, reason: "Goals not found")
        }
        return userGoals
    }
    
    func updateUserGoals(req: Request) async throws -> UserGoalsDTO {
        let userId = try req.auth.require(User.self).id!
        let goalsDTO = try req.content.decode(UserGoalsDTO.self)
        
        let updatedGoals = try await userProfileService.updateUserGoals(userId: userId, goals: goalsDTO, on: req.db)
        return updatedGoals
    }
}
