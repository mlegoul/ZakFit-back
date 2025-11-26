//
//  AuthService.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Vapor
import JWT
import Fluent

struct AuthService {
    
    func generateToken(for user: User, on req: Request) async throws -> String {
        let payload = AuthJWTPayload(
            subject: .init(value: user.id!.uuidString),
            expiration: .init(value: Date().addingTimeInterval(604800)),
            userId: user.id!
        )
        return try req.jwt.sign(payload)
    }
    
    func authenticate(email: String, password: String, on req: Request) async throws -> User {
        // Récupérer l'utilisateur par email
        guard let user = try await User.query(on: req.db)
            .filter(\User.$email == email)
            .first() else {
            throw Abort(.unauthorized, reason: "Email ou mot de passe incorrect")
        }
        
        
        let isValidPassword = try Bcrypt.verify(password, created: user.passwordHash)
        
        guard isValidPassword else {
            throw Abort(.unauthorized, reason: "Email ou mot de passe incorrect")
        }
        
        return user
    }
    
    struct AuthJWTPayload: JWTPayload {
        var subject: SubjectClaim
        var expiration: ExpirationClaim
        var userId: UUID
        
        func verify(using signer: JWTSigner) throws {
            try expiration.verifyNotExpired()
        }
    }
}
