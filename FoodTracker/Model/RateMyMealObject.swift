//
//  RestfulAPICalls.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/12/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import Foundation

struct User: Decodable {
    
    var id: Int
    var userUuid: String
    var username: String
    var password: String
    var email: String
    var createdAt: String
    var updatedAt: String
    var ratings: [Rating]
    
}

struct Rating: Decodable {
    
    var id: Int
    var ratingUuid: String
    var ratingScore: Int
    var createdAt: String
    var updatedAt: String
    var mealId: Int
    var userId: Int
    var meal: RatedMeal
        
        
    struct RatedMeal: Decodable {
        var id: Int
        var mealUuid: String
        var mealName: String
        var imagePath: String
        var createdAt: String
        var updatedAt: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case ratingUuid
        case ratingScore
        case createdAt
        case updatedAt
        case mealId
        case userId
        case meal
      }
}
