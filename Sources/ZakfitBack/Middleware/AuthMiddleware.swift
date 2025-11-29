//
//  AuthMiddleware.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Vapor
import JWT

struct AuthMiddleware: AsyncMiddleware {
    
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        
        guard let authHeader = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Missing authorization header")
        }
        
        do {
            
            let payload = try request.jwt.verify(
                authHeader.token,
                as: AuthService.AuthJWTPayload.self
            )
            
            guard let user = try await User.find(payload.userId, on: request.db) else {
                throw Abort(.unauthorized, reason: "User not found")
            }
            
            request.auth.login(user)
            
            return try await next.respond(to: request)
            
        } catch let error as JWTError {

            throw Abort(
                .unauthorized,
                reason: "Invalid token: \(error.localizedDescription)"
            )
        } catch {
            
            throw Abort(.unauthorized, reason: "Authentication failed")
        }
    }
}
