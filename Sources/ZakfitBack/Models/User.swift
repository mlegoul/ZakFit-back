//
//  User.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Fluent
import Vapor

final class User: Model, @unchecked Sendable, Authenticatable {
    static let schema = "User"
    
    @ID(custom: "user_id")
    var id: UUID?
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var passwordHash: String
    
    @Field(key: "height")
    var height: Int?
    
    @Field(key: "weight")
    var weight: Int?
    
    @Field(key: "goals")
    var goals: String?
    
    @Field(key: "age")
    var age: Int?
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        email: String,
        passwordHash: String,
        height: Int? = nil,
        weight: Int? = nil,
        goals: String? = nil,
        age: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.height = height
        self.weight = weight
        self.goals = goals
        self.age = age
    }
}
