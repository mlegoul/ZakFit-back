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
            dietaryPreferences: goals,
            activityLevel: nil,
            age: age,
            sex: nil
        )
    }
}
