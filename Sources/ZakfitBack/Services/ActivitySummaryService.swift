//
//  ActivitySummaryService.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 02/12/2025.
//

import Fluent
import Vapor

struct ActivitySummaryService: Sendable {
    private let repository: any ActivitySummaryRepositoryProtocol
    
    init(
        repository: any ActivitySummaryRepositoryProtocol = ActivitySummaryRepository()
    ) {
        self.repository = repository
    }
    
    func getDailyActivitySummary(for userId: UUID, on date: Date, db: any Database) async throws -> DailyActivitySummary {
        return try await repository
            .getDailyActivitySummary(for: userId, on: date, db: db)
    }
}
