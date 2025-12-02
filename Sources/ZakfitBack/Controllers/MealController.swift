//
//  MealController.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Vapor
import Fluent

struct MealController: RouteCollection {
    
    let foodItemService: FoodItemService
    let foodItemRepository: FoodItemRepository
    
    init(
        foodItemService: FoodItemService,
        foodItemRepository: FoodItemRepository = FoodItemRepository()
    ) {
        self.foodItemService = foodItemService
        self.foodItemRepository = foodItemRepository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let mealsRoute = routes.grouped("meals")
        let protectedRoutes = mealsRoute.grouped(AuthMiddleware())
        protectedRoutes.post(use: createMeal)
    }
    
    func createMeal(req: Request) async throws -> MealResponse {
        
        let user = try req.auth.require(User.self)
        let createMealRequest = try req.content.decode(CreateMealRequest.self)
        _ = createMealRequest.date ?? Date()
        
        let meal = Meal(
            userId: try user.requireID(),
            type: createMealRequest.type,
            calories: 0,
            date: createMealRequest.date ?? Date()
        )
        
        try await req.db.transaction { db in
            try await meal.save(on: db)
            var totalCalories = 0
            
            let foodItemNames = createMealRequest.foodItems.map {
                $0.name.lowercased()
            }
            let existingFoodItems = try await FoodItem.query(on: db)
                .group(.or) { or in
                    for name in foodItemNames {
                        or.filter(\.$name == name)
                    }
                }
                .all()
            
            let existingFoodItemsDict = Dictionary(
                uniqueKeysWithValues: existingFoodItems
                    .map { ($0.name.lowercased(), $0) }
            )
            
            for foodItemRequest in createMealRequest.foodItems {
                let lowercasedName = foodItemRequest.name.lowercased()
                if let existingFoodItem = existingFoodItemsDict[lowercasedName] {
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
                } else {
                    print(
                        "Aliment non trouvé en base, appel API pour : \(foodItemRequest.name)"
                    )
                    let foodItemResponse = try await withThrowingTaskGroup(
                        of: FoodItemResponse.self
                    ) { group in
                        group
                            .addTask {
                                try await self.foodItemService
                                    .fetchFoodItemData(
                                        name: foodItemRequest.name
                                    )
                            }
                        try await Task
                            .sleep(nanoseconds: 3_000_000_000) // Timeout 3s
                        guard let result = try await group.next() else {
                            throw Abort(
                                .requestTimeout,
                                reason: "API externe trop lente"
                            )
                        }
                        return result
                    }
                    
                    let newFoodItem = FoodItem(
                        name: foodItemResponse.name.lowercased(),
                        referenceQuantity: 100,
                        unit: "g",
                        calories: foodItemResponse.calories,
                        proteins: foodItemResponse.proteins,
                        carbs: foodItemResponse.carbs,
                        fats: foodItemResponse.fats
                    )
                    try await foodItemRepository
                        .createFoodItem(newFoodItem, on: db)
                    
                    let calories = Int(
                        foodItemResponse.calories * Double(
                            foodItemRequest.consumedQuantity
                        ) / 100.0
                    )
                    totalCalories += calories
                    
                    let mealFoodItem = MealFoodItem(
                        mealId: try meal.requireID(),
                        foodItemId: try newFoodItem.requireID(),
                        consumedQuantity: foodItemRequest.consumedQuantity
                    )
                    try await mealFoodItem.save(on: db)
                }
            }
            
            print("Total calories calculé : \(totalCalories)")
            meal.calories = totalCalories
            try await meal.update(on: db)
        }
        
        return MealResponse(
            id: try meal.requireID(),
            type: meal.type,
            calories: meal.calories,
            date: meal.date
        )
    }
}
