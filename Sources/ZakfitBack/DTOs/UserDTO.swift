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
    let name: String
    let email: String
    let height: Int?
    let weight: Int?
    let goals: String?
    let age: Int?
}

extension User {
    func makePublic() -> UserPublic {
        return UserPublic(
            id: id,
            name: name,
            email: email,
            height: height,
            weight: weight,
            goals: goals,
            age: age
        )
    }
}
