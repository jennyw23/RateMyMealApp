//
//  OtherNetworkingCalls.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/17/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import Foundation
import Alamofire

class OtherNetworking {
    
    // Note: these shouldn't be possible within scope of user. however, it could be helpful to use them again for when
    // I do an admin access login
    
    func getMeals() {
        AF.request("http://localhost:3000/meals/")
        .validate()
            .responseDecodable(of: [Meal2].self) { (response) in
                guard let mealData = response.value else {
                    print("Error fetching meal data: \(String(describing: response.error))")
                    return
                }
                print("All Meals in Database: ")
                for meal in mealData {
                    print(meal.mealName)
                }
            }
    }
    func postMeal(mealName: String) {
        let url: String = "http://localhost:3000/meals"
        
        let params: [String: String] = [
            "mealName": mealName
        ]

        AF.request(url, method: .post, parameters: params).responseString { (response) in
            guard response.value != nil else {
                print("Post request failed: \(String(describing: response.error))")
                return
            }
            print("posted meals!")
        }
    }
    
    // This is for posting a rating from any user. See postMealRating() for the proper one in this app
    func postRating(userUuid: String, mealUuid: String, ratingScore: Int) {
        let url: String = "http://localhost:3000/ratings"

        let params: [String: Any] = [
            "userUuid": userUuid,
            "mealUuid": mealUuid,
            "ratingScore": ratingScore
        ]

        AF.request(url, method: .post, parameters: params).responseString { (response) in
            guard response.value != nil else {
                print("Post request failed: \(String(describing: response.error))")
                return
            }
            print("posted rating to user \(userUuid)!")
        }
    }

    // This gets all ratings from a user. Adapt this method for my app to load meals
    func getUserRatings(userUuid: String) {
        var userRatings: [MealDataModel] = []
        
        AF.request("http://localhost:3000/ratings/user/\(userUuid)")
        .validate()
        .responseDecodable(of: [User].self) { (response) in
          guard let userData = response.value else {
            print("FetchSingerUser Error: \(String(describing: response.error))")
            return }
            
            for rating in userData[0].ratings {
                let mealName = rating.meal.mealName
                let spoonacularPhoto = rating.meal.imagePath
                let ratingScore = rating.ratingScore
                guard let cell = MealDataModel(name: mealName, photo: UIImage(named: "meal1"), spoonacularPhoto: spoonacularPhoto, rating: ratingScore) else {
                    print("MealDataModel Initialization Error: check MealDataModel object for loop")
                    return
                }
                userRatings.append(cell)
            }
            
            
        }
      }

    func getUserJSONData() {
        AF.request("http://localhost:3000/users/")
        .validate()
        .responseJSON { (data) in
              print(data)
            }
    }

    
}

