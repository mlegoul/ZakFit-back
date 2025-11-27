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
}
