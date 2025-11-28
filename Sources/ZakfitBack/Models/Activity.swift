//
//  Activity.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 28/11/2025.
//

import Fluent
import Vapor

final class Activity: Model, Content, @unchecked Sendable {
    static let schema = "activity"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "duration")
    var duration: Int
    
    @Field(key: "calories")
    var calories: Int
    
    @Timestamp(key: "date", on: .create)
    var date: Date?
    
    @Parent(key: "user_id")
    var user: User
    
    init() { }
    
    init(
        id: UUID? = nil,
        userId: UUID,
        type: String,
        duration: Int,
        calories: Int,
        date: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.duration = duration
        self.calories = calories
        self.date = date
    }
}
