//
//  Meal.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Fluent
import Vapor

final class Meal: Model, Content, @unchecked Sendable {
    static let schema = "meal"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "calories")
    var calories: Int
    
    @Timestamp(key: "date", on: .create)
    var date: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        userId: UUID,
        type: String,
        calories: Int,
        date: Date? = nil
    ) {
        self.id = id
        self.$user.id = userId
        self.type = type
        self.calories = calories
        self.date = date
    }
}
