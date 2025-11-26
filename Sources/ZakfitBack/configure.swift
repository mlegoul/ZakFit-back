import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    
    // MARK: - CORS
    let corsConfig = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .PATCH, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent],
        allowCredentials: true
    )
    
    app.middleware.use(CORSMiddleware(configuration: corsConfig))


    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .mysql)
    
    
    // Migrations
    app.migrations.add(CreateUser())
    
    //MARK: - JWT Signer
    guard let jwtSecret = Environment.get("JWT_SECRET") else {
        fatalError("JWT_SECRET not set in environment variables")
    }
    
    app.jwt.signers.use(.hs256(key: jwtSecret))
    
    
    // register routes
    try routes(app)
}
