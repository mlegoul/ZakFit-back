//
//  AuthDTO.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Vapor

// MARK: - Requests
struct RegisterRequest: Content {
    let firstName: String
    let lastName: String
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

// MARK: - DTOs
struct UserLoginDTO: Content, Validatable {
    var email: String
    var password: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .password)
    }
}

struct UserRegisterDTO: Content, Validatable {
    let firstName: String
    let lastName: String
    var email: String
    var password: String
    var passwordConfirmation: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("firstName", as: String.self, is: .firstName)
        validations.add("lastName", as: String.self, is: .lastName)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .password)
    }
}

// MARK: - UserRegisterDTO+Validation
extension UserRegisterDTO {
    func validatePasswordMatch() throws {
        guard password == passwordConfirmation else {
            throw Abort(.badRequest, reason: "Les mots de passe ne correspondent pas.")
        }
    }
}
