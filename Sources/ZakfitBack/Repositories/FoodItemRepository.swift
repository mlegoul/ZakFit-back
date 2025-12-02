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
    
    func createMeal(
        userId: UUID,
        type: String,
        foodItems: [CreateMealFoodItemRequest],
        date: Date,
        on db: any Database
    ) async throws -> MealResponse
    
    func getMealHistory(userId: UUID,on db: any Database) async throws -> [MealHistoryResponse]
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
    
    func createMeal(
        userId: UUID,
        type: String,
        foodItems: [CreateMealFoodItemRequest],
        date: Date,
        on db: any Database
    ) async throws -> MealResponse {

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: date
        )!
        
        if let existingMeal = try await Meal.query(on: db)
            .filter(\.$user.$id == userId)
            .filter(\.$type == type)
            .filter(\.$date >= startOfDay)
            .filter(\.$date <= endOfDay)
            .first() {
            
            var totalCalories = Int(existingMeal.calories)
            
            for foodItemRequest in foodItems {
                let lowercasedName = foodItemRequest.name.lowercased()
                guard let existingFoodItem = try await getFoodItemByName(lowercasedName, on: db) else {
                    throw Abort(
                        .notFound,
                        reason: "Aliment non trouvé en base de données : \(foodItemRequest.name)"
                    )
                }
                
                let calories = Int(
                    existingFoodItem.calories * Double(
                        foodItemRequest.consumedQuantity
                    ) / 100.0
                )
                totalCalories += calories
                
                let mealFoodItem = MealFoodItem(
                    mealId: try existingMeal.requireID(),
                    foodItemId: try existingFoodItem.requireID(),
                    consumedQuantity: foodItemRequest.consumedQuantity
                )
                try await mealFoodItem.save(on: db)
            }
            
            existingMeal.calories = totalCalories
            try await existingMeal.update(on: db)
            
            return MealResponse(
                id: try existingMeal.requireID(),
                type: existingMeal.type,
                calories: existingMeal.calories,
                date: existingMeal.date
            )
        } else {

            let meal = Meal(
                userId: userId,
                type: type,
                calories: 0,
                date: date
            )
            
            try await meal.save(on: db)
            var totalCalories = 0
            
            for foodItemRequest in foodItems {
                let lowercasedName = foodItemRequest.name.lowercased()
                guard let existingFoodItem = try await getFoodItemByName(lowercasedName, on: db) else {
                    throw Abort(
                        .notFound,
                        reason: "Aliment non trouvé en base de données : \(foodItemRequest.name)"
                    )
                }
                
                let calories = Int(
                    existingFoodItem.calories * Double(
                        foodItemRequest.consumedQuantity
                    ) / 100.0
                )
                totalCalories += calories
                
                let mealFoodItem = MealFoodItem(
                    mealId: try meal.requireID(),
                    foodItemId: try existingFoodItem.requireID(),
                    consumedQuantity: foodItemRequest.consumedQuantity
                )
                try await mealFoodItem.save(on: db)
            }
            
            meal.calories = totalCalories
            try await meal.update(on: db)
            
            return MealResponse(
                id: try meal.requireID(),
                type: meal.type,
                calories: meal.calories,
                date: meal.date
            )
        }
    }
    
    func getMealHistory(
        userId: UUID,
        on db: any Database
    ) async throws -> [MealHistoryResponse] {
        let meals = try await Meal.query(on: db)
            .filter(\.$user.$id == userId)
            .all()
        
        var mealHistoryResponses = [MealHistoryResponse]()
        
        for meal in meals {
            let mealFoodItems = try await MealFoodItem.query(on: db)
                .filter(\.$meal.$id == meal.id!)
                .all()
            
            var foodItemResponses = [MealFoodItemResponse]()
            
            for mealFoodItem in mealFoodItems {
                guard let foodItem = try await FoodItem.find(mealFoodItem.$foodItem.id, on: db) else {
                    continue
                }
                
                foodItemResponses.append(MealFoodItemResponse(
                    id: try foodItem.requireID(),
                    name: foodItem.name,
                    consumedQuantity: mealFoodItem.consumedQuantity,
                    calories: foodItem.calories * Double(mealFoodItem.consumedQuantity) / 100.0,
                    proteins: foodItem.proteins * Double(mealFoodItem.consumedQuantity) / 100.0,
                    carbs: foodItem.carbs * Double(mealFoodItem.consumedQuantity) / 100.0,
                    fats: foodItem.fats * Double(mealFoodItem.consumedQuantity) / 100.0
                ))
            }
            
            mealHistoryResponses.append(MealHistoryResponse(
                id: try meal.requireID(),
                type: meal.type,
                calories: meal.calories,
                date: meal.date,
                foodItems: foodItemResponses
            ))
        }
        
        return mealHistoryResponses
    }
}
