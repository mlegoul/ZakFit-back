//
//  AuthDTO.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Vapor

// MARK: - Requests
struct RegisterRequest: Content {
    let name: String
    let email: String
    let password: String
}

struct LoginRequest: Content {
    let email: String
    let password: String
}

// MARK: - Responses
struct TokenResponse: Content {
    let token: String
}

struct RegisterResponse: Content {
    let user: UserPublic
    let token: String
}
