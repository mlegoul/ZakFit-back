//
//  FoodItemService.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Vapor
import Fluent

struct FoodItemService {
    let client: any Client
    let apiKey: String
    let foodItemRepository: any FoodItemRepositoryProtocol
    
    init(
        client: any Client,
        apiKey: String = Environment.get("apiKey") ?? "",
        foodItemRepository: any FoodItemRepositoryProtocol = FoodItemRepository()
    ) {
        self.client = client
        self.apiKey = apiKey
        self.foodItemRepository = foodItemRepository
    }
    
    func createMeal(
        userId: UUID,
        type: String,
        foodItems: [CreateMealFoodItemRequest],
        date: Date,
        on db: any Database
    ) async throws -> MealResponse {
        for foodItemRequest in foodItems {
            let lowercasedName = foodItemRequest.name.lowercased()
            if try await foodItemRepository
                .getFoodItemByName(lowercasedName, on: db) == nil {
                let foodItemResponse = try await fetchFoodItemData(
                    name: foodItemRequest.name
                )
                let newFoodItem = FoodItem(
                    name: foodItemResponse.name.lowercased(),
                    referenceQuantity: 100,
                    unit: "g",
                    calories: foodItemResponse.calories,
                    proteins: foodItemResponse.proteins,
                    carbs: foodItemResponse.carbs,
                    fats: foodItemResponse.fats
                )
                try await foodItemRepository.createFoodItem(newFoodItem, on: db)
            }
        }
        
        return try await foodItemRepository.createMeal(
            userId: userId,
            type: type,
            foodItems: foodItems,
            date: date,
            on: db
        )
    }

    func fetchFoodItemData(name: String) async throws -> FoodItemResponse {
        let encodedFoodName = name.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""
        let urlString = "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(encodedFoodName)&search_simple=1&action=process&json=1&fields=product_name,nutriments"
        let url = URI(string: urlString)
        
        let response = try await client.get(url)
        
        guard response.status == .ok else {
            throw Abort(
                .badRequest,
                reason: "Erreur lors de la récupération des données de l'API Open Food Facts"
            )
        }
        
        let foodData = try response.content.decode(OpenFoodFactsResponse.self)
        
        guard let firstProduct = foodData.products.first else {
            throw Abort(.notFound, reason: "Aucun produit trouvé pour \(name)")
        }
        
        let productName = firstProduct.productName ?? name
        let calories = firstProduct.nutriments.energyKcal100g ?? 0
        let proteins = firstProduct.nutriments.proteins100g ?? 0
        let carbs = firstProduct.nutriments.carbohydrates100g ?? 0
        let fats = firstProduct.nutriments.fat100g ?? 0
        
        return FoodItemResponse(
            name: productName,
            calories: calories,
            proteins: proteins,
            carbs: carbs,
            fats: fats
        )
    }
}
