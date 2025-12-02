//
//  MealController.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Vapor

struct MealController: RouteCollection {
    
    let foodItemService: FoodItemService
    
    init(foodItemService: FoodItemService) {
        self.foodItemService = foodItemService
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let mealsRoute = routes.grouped("meals")
        let protectedRoutes = mealsRoute.grouped(AuthMiddleware())
        protectedRoutes.post(use: createMeal)
    }
    
    func createMeal(req: Request) async throws -> MealResponse {
        let user = try req.auth.require(User.self)
        let createMealRequest = try req.content.decode(CreateMealRequest.self)
        
        let mealResponse = try await foodItemService.createMeal(
            userId: try user.requireID(),
            type: createMealRequest.type,
            foodItems: createMealRequest.foodItems,
            date: createMealRequest.date ?? Date(),
            on: req.db
        )
        
        return mealResponse
    }
}
