//
//  MealFoodItem.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 01/12/2025.
//

import Fluent
import Vapor

final class MealFoodItem: Model, Content, @unchecked Sendable {
    static let schema = "meal_foodItem"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "meal_id")
    var meal: Meal
    
    @Parent(key: "fooditem_id")
    var foodItem: FoodItem
    
    @Field(key: "consumed_quantity")
    var consumedQuantity: Int
    
    init() { }
    
    init(id: UUID? = nil, mealId: Meal.IDValue, foodItemId: FoodItem.IDValue, consumedQuantity: Int) {
        self.id = id
        self.$meal.id = mealId
        self.$foodItem.id = foodItemId
        self.consumedQuantity = consumedQuantity
    }
}
