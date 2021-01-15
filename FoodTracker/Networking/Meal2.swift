//
//  Meal2.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/14/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import Foundation

struct Meal2: Decodable {
    
    var id: Int
    var mealUuid: String
    var mealName: String
    var createdAt: String
    var updatedAt: String
}
