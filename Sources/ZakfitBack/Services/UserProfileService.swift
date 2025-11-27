//
//  UserProfileService.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 26/11/2025.
//

import Vapor
import Fluent

struct UserProfileService {
    let userRepository: any UserRepositoryProtocol
    
    init(userRepository: any UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }
    
    func getUserInfo(userId: UUID, on db: any Database) async throws -> UserPublic? {
        guard let user = try await userRepository.getUser(byId: userId, on: db) else {
            return nil
        }
        return user.makePublic()
    }
    
    func getUserHealth(userId: UUID, on db: any Database) async throws -> UserHealthDTO? {
        guard let user = try await userRepository.getUser(byId: userId, on: db) else {
            return nil
        }
        return user.makeHealthDTO()
    }
    
    func getUserGoals(userId: UUID, on db: any Database) async throws -> UserGoalsDTO? {
        guard let user = try await User.find(userId, on: db) else {
            return nil
        }
        
        guard let goalsJSON = user.goals,
              let goalsData = goalsJSON.data(using: .utf8),
              let goalsDTO = try? JSONDecoder().decode(UserGoalsDTO.self, from: goalsData) else {
            return nil
        }
        return goalsDTO
    }
    
    func updateUserGoals(userId: UUID, goals: UserGoalsDTO, on db: any Database) async throws -> UserGoalsDTO {
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        let currentGoals = try await getUserGoals(userId: userId, on: db) ?? UserGoalsDTO()
        
        let mergedGoals = mergeGoals(
            currentGoals: currentGoals,
            newGoals: goals
        )
        
        let goalsJSON = try encodeGoalsToJSON(mergedGoals)
        user.goals = goalsJSON
        
        try await user.update(on: db)
        
        return mergedGoals
    }
    
    private func mergeGoals(currentGoals: UserGoalsDTO, newGoals: UserGoalsDTO) -> UserGoalsDTO {
        return UserGoalsDTO(
            targetCalories: newGoals.targetCalories ?? currentGoals.targetCalories,
            targetDuration: newGoals.targetDuration ?? currentGoals.targetDuration,
            frequency: newGoals.frequency ?? currentGoals.frequency
        )
    }
    
    private func encodeGoalsToJSON(_ goals: UserGoalsDTO) throws -> String? {
        let goalsData = try JSONEncoder().encode(goals)
        return String(data: goalsData, encoding: .utf8)
    }
    
    func updateUserInfo(userId: UUID, info: UserPublicUpdateDTO, on db: any Database) async throws -> User {
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        if let firstName = info.firstName {
            user.firstName = firstName
        }
        if let lastName = info.lastName {
            user.lastName = lastName
        }
        if let email = info.email {
            user.email = email
        }
        
        try await user.update(on: db)
        return user
    }
    
    func updateUserHealth(userId: UUID, health: UserHealthUpdateDTO, on db: any Database) async throws -> User {
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        if let height = health.height {
            user.height = height
        }
        if let weight = health.weight {
            user.weight = weight
        }
        if let dietaryPreferences = health.dietaryPreferences {
            user.dietaryPreferences = dietaryPreferences
        }
        if let activityLevel = health.activityLevel {
            user.activityLevel = activityLevel
        }
        if let age = health.age {
            user.age = age
        }
        if let sex = health.sex {
            user.sex = sex
        }
        
        try await user.update(on: db)
        return user
    }
    
    func deleteUser(userId: UUID, on db: any Database) async throws {
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        try await user.delete(on: db)
    }
}
