//
//  Rating.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/12/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import Foundation

struct Rating: Decodable {
    
    var id: Int
    var ratingUuid: String
    var ratingScore: String
    var createdAt: String
    var updatedAt: String
    var mealId: Int
    var userId: Int
    var meal: RatedMeal
        
        
    struct RatedMeal: Decodable {
        var id: Int
        var mealUuid: String
        var mealName: String
        var createdAt: String
        var updatedAt: String
    }
}
