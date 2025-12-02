//
//  FoodItemService.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Vapor

struct FoodItemService {
    
    let client: any Client
    let apiKey: String
    
    init(
        client: any Client,
        apiKey: String = Environment.get("apiKey") ?? ""
    ) {
        self.client = client
        self.apiKey = apiKey
    }
    
    
    func fetchFoodItemData(name: String) async throws -> FoodItemResponse {
        let encodedFoodName = name.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""
        let urlString = "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(encodedFoodName)&search_simple=1&action=process&json=1&fields=product_name,nutriments"

        do {
            let url = URI(string: urlString)
            let response = try await client.get(url)
            
            guard response.status == .ok else {
                throw Abort(
                    .badRequest,
                    reason: "Erreur lors de la récupération des données de l'API Open Food Facts"
                )
            }
            
            let foodData = try response.content.decode(
                OpenFoodFactsResponse.self
            )
            
            guard let firstProduct = foodData.products.first else {
                throw Abort(
                    .notFound,
                    reason: "Aucun produit trouvé pour \(name)"
                )
            }
            
            return FoodItemResponse(
                name: firstProduct.productName ?? name,
                calories: firstProduct.nutriments.energyKcal100g ?? 0,
                proteins: firstProduct.nutriments.proteins100g ?? 0,
                carbs: firstProduct.nutriments.carbohydrates100g ?? 0,
                fats: firstProduct.nutriments.fat100g ?? 0
            )
        } catch {
            throw Abort(.badRequest, reason: "URL invalide ou erreur réseau")
        }
    }
}
