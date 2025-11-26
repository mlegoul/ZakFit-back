//
//  UserRepository.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Vapor
import Fluent

protocol UserRepositoryProtocol: Sendable {
    func create(user: User, on db: any Database) async throws -> User
    
    func exists(byEmail email: String, on db: any Database) async throws -> Bool
}

struct UserRepository: UserRepositoryProtocol {
    func create(user: User, on db: any Database) async throws -> User {
        try await user.save(on: db)
        return user
    }
    
    func exists(byEmail email: String, on db: any Database) async throws -> Bool {
        try await User.query(on: db)
            .filter(\User.$email == email)
            .first() != nil
    }
}
