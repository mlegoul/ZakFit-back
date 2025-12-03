//
//  DailyActivitySummaryDTO.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 02/12/2025.
//

import Vapor

struct DailyActivitySummaryResponse: Content {
    let userId: UUID
    let date: Date
    let type: String
    let totalDuration: Int
    let totalCalories: Int
    let message: String?
    
    init(
        userId: UUID,
        date: Date,
        type: String,
        totalDuration: Int,
        totalCalories: Int,
        message: String? = nil
    ) {
        self.userId = userId
        self.date = date
        self.type = type
        self.totalDuration = totalDuration
        self.totalCalories = totalCalories
        self.message = message
    }
}
