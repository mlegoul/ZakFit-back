//
//  UserDTOs.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 26/11/2025.
//

import Vapor

// MARK: - Responses
struct UserPublic: Content {
    let id: UUID?
    let firstName: String
    let lastName: String
    let email: String
}

struct UserHealthDTO: Content {
    let height: Int?
    let weight: Int?
    let dietaryPreferences: String?
    let activityLevel: String?
    let age: Int?
    let sex: String?
}


extension User {
    func makePublic() -> UserPublic {
        return UserPublic(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email
        )
    }
    
    func makeHealthDTO() -> UserHealthDTO {
        return UserHealthDTO(
            height: height,
            weight: weight,
            dietaryPreferences: dietaryPreferences,
            activityLevel: activityLevel,
            age: age,
            sex: sex
        )
    }
}

struct UserGoalsDTO: Content {
    var targetCalories: Int?
    var targetDuration: Int?
    var frequency: String?
    
    init(targetCalories: Int? = nil, targetDuration: Int? = nil, frequency: String? = nil) {
        self.targetCalories = targetCalories
        self.targetDuration = targetDuration
        self.frequency = frequency
    }
}

struct UserPublicUpdateDTO: Content {
    var firstName: String?
    var lastName: String?
    var email: String?
}

struct UserHealthUpdateDTO: Content {
    var height: Int?
    var weight: Int?
    var dietaryPreferences: String?
    var activityLevel: String?
    var age: Int?
    var sex: String?
}
