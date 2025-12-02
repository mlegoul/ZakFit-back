//
//  AuthController.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 25/11/2025.
//

import Vapor
import Fluent

struct AuthController: RouteCollection {
    let authService: AuthService
    let userRepository: any UserRepositoryProtocol
    
    init(
        authService: AuthService = AuthService(),
        userRepository: any UserRepositoryProtocol = UserRepository()
    ) {
        self.authService = authService
        self.userRepository = userRepository
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")
        
        authRoutes.post("register", use: register)
        authRoutes.post("login", use: login)
    }
    
    // MARK: - Register
    func register(req: Request) async throws -> RegisterResponse {
        
        let dto = try req.content.decode(UserRegisterDTO.self)
        try UserRegisterDTO.validate(content: req)
        
        guard dto.password == dto.passwordConfirmation else {
            throw Abort(.badRequest, reason: "Les mots de passe ne correspondent pas.")
        }
        
        guard try await !userRepository
            .exists(byEmail: dto.email, on: req.db) else {
            throw Abort(
                .conflict,
                reason: "Un utilisateur avec cet email existe déjà."
            )
        }
        
        let passwordHash = try await req.password.async.hash(
            dto.password
        )
        
        let user = User(
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email,
            passwordHash: passwordHash
        )
        
        let createdUser = try await userRepository.create(
            user: user,
            on: req.db
        )
        
        let token = try await authService.generateToken(for: createdUser, on: req)
        
        return RegisterResponse(user: createdUser.makePublic(), token: token)
    }
    
    // MARK: - Login
    func login(req: Request) async throws -> TokenResponse {
        
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        try UserLoginDTO.validate(content: req)
        
        guard let user = try await User.query(on: req.db)
            .filter(\User.$email == loginRequest.email)
            .first() else {
            throw Abort(.notFound, reason: "Email ou mot de passe incorrect.")
        }
        
        let isValidPassword = try await req.password.async.verify(
            loginRequest.password,
            created: user.passwordHash
        )

        
        guard isValidPassword else {
            throw Abort(.notFound, reason: "Email ou mot de passe incorrect.")
        }
        
        let token = try await authService.generateToken(for: user, on: req)
        
        return TokenResponse(token: token)
    }
}
