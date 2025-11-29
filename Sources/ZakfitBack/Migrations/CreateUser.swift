//
//  CreateUser.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("User")
            .field("user_id", .uuid, .identifier(auto: false))
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("height", .int)
            .field("weight", .int)
            .field("goals", .string)
            .field("age", .int)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("User").delete()
    }
}
