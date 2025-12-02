//
//  MealDTOs.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Vapor

// MARK: - Requests
struct CreateMealRequest: Content {
    let type: String
    let foodItems: [CreateMealFoodItemRequest]
    let calories: Int?
    let date: Date?
}

struct CreateMealFoodItemRequest: Content {
    let name: String
    let consumedQuantity: Int
}

// MARK: - Responses
struct MealResponse: Content {
    let id: UUID
    let type: String
    let calories: Int
    let date: Date?
}

struct MealHistoryResponse: Content {
    let id: UUID
    let type: String
    let calories: Int
    let date: Date?
    let foodItems: [MealFoodItemResponse]
}

struct MealFoodItemResponse: Content {
    let id: UUID
    let name: String
    let consumedQuantity: Int
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
}

// MARK: - Open Food Facts API
struct OpenFoodFactsResponse: Content {
    let products: [Product]
    
    struct Product: Content {
        let productName: String?
        let nutriments: Nutriments
        
        struct Nutriments: Content {
            let energyKcal100g: Double?
            let proteins100g: Double?
            let carbohydrates100g: Double?
            let fat100g: Double?
            
            enum CodingKeys: String, CodingKey {
                case energyKcal100g = "energy-kcal_100g"
                case proteins100g = "proteins_100g"
                case carbohydrates100g = "carbohydrates_100g"
                case fat100g = "fat_100g"
            }
        }
    }
}

// MARK: - Standardized Food Item
struct FoodItemResponse: Content {
    let name: String
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
}
