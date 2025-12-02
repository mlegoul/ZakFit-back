//
//  FoodItem.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Fluent
import Vapor

final class FoodItem: Model, Content, @unchecked Sendable {
    static let schema = "foodItem"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "reference_quantity")
    var referenceQuantity: Int
    
    @Field(key: "unit")
    var unit: String
    
    @Field(key: "calories")
    var calories: Double
    
    @Field(key: "proteins")
    var proteins: Double
    
    @Field(key: "carbs")
    var carbs: Double
    
    @Field(key: "fats")
    var fats: Double
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        referenceQuantity: Int = 100,
        unit: String = "g",
        calories: Double,
        proteins: Double,
        carbs: Double,
        fats: Double
    ) {
        self.id = id
        self.name = name
        self.referenceQuantity = referenceQuantity
        self.unit = unit
        self.calories = calories
        self.proteins = proteins
        self.carbs = carbs
        self.fats = fats
    }
}
