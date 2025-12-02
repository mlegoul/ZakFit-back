import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    try app.register(collection: AuthController())
    try app.register(collection: UserProfileController())
    try app.register(collection: ActivityController())
    try app.register(collection: MealController(foodItemService: FoodItemService(client: app.client)))
}
