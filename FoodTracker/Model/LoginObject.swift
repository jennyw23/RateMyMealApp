//
//  LoginObject.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/21/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import Foundation

struct Login: Decodable {
    
    var success: Bool
    var message: String
    var token: String?
    var userUuid: String?
}
