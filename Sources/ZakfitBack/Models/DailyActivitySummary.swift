//
//  DailyActivitySummary.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 03/12/2025.
//

import Vapor

struct DailyActivitySummary {
    let userId: UUID
    let date: Date
    let type: String
    let totalDuration: Int
    let totalCalories: Int
    
    init(
        userId: UUID,
        date: Date,
        type: String,
        totalDuration: Int,
        totalCalories: Int
    ) {
        self.userId = userId
        self.date = date
        self.type = type
        self.totalDuration = totalDuration
        self.totalCalories = totalCalories
    }
}
