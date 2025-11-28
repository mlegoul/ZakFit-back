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
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
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
    
    @Field(key: "dietary_preferences")
    var dietaryPreferences: String?
    
    @Field(key: "activity_level")
    var activityLevel: String?
    
    @Field(key: "sex")
    var sex: String?
    
    @Children(for: \.$user)
    var activities: [Activity]
    
    init() { }
    
    init(
        id: UUID? = nil,
        firstName: String,
        lastName: String,
        email: String,
        passwordHash: String,
        height: Int? = nil,
        weight: Int? = nil,
        goals: String? = nil,
        age: Int? = nil,
        dietaryPreferences: String? = nil,
        activityLevel: String? = nil,
        sex: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.passwordHash = passwordHash
        self.height = height
        self.weight = weight
        self.goals = goals
        self.age = age
        self.dietaryPreferences = dietaryPreferences
        self.activityLevel = activityLevel
        self.sex = sex
    }
}
