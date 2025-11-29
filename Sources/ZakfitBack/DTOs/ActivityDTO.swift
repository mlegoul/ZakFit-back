//
//  ActivityDTO.swift
//  ZakfitBack
//
//  Created by Mehdi Legoullon on 28/11/2025.
//

import Vapor

// MARK: - Response
struct CreateActivityDTO: Content {
    let type: String
    let duration: Int
    let calories: Int
    let date: Date?
}

struct ActivityResponseDTO: Content {
    let type: String
    let duration: Int
    let calories: Int
    let date: Date
}
