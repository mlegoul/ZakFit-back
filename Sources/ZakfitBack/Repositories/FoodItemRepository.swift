//
//  FoodItemRepository.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Fluent
import Vapor

protocol FoodItemRepositoryProtocol: Sendable {
    func createFoodItem(_ foodItem: FoodItem, on db: any Database) async throws
    func getFoodItemByName(_ name: String, on db: any Database) async throws -> FoodItem?
}

struct FoodItemRepository: FoodItemRepositoryProtocol {
    func createFoodItem(_ foodItem: FoodItem, on db: any Database) async throws {
        try await foodItem.save(on: db)
    }
    
    func getFoodItemByName(_ name: String, on db: any Database) async throws -> FoodItem? {
        try await FoodItem.query(on: db)
            .filter(\.$name == name)
            .first()
    }
}
