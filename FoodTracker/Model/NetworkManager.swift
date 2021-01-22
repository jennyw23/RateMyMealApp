//
//  NetworkManager.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/16/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager {
        
    static var userUuid: String = ""
    static var bearerToken: String = ""
    
    // MARK: RateMyMeal REST API Calls
    
    func postLoginCredentials(username: String, password: String, completion: @escaping () -> Void) {
        let url: String = "http://localhost:3000/login"
        
        let params: [String: Any] = [
            "username": username,
            "password": password,
        ]

        AF.request(url, method: .post, parameters: params).responseString { (response) in
            
            guard let result = response.data else {
                print("Post request failed: \(String(describing: response.error))")
                return
            }
            
            do {
                let loginResponse = try JSONDecoder().decode(Login.self, from: result)
                // set user bearer token
                NetworkManager.userUuid = loginResponse.userUuid
                NetworkManager.bearerToken = loginResponse.token
                print("userUuid: \(NetworkManager.userUuid) and bearer Token: \(NetworkManager.bearerToken)")

            } catch {
                print(error)
            }
            print("Retrieved user bearer token! arrived at completion handler")
            completion()
        }
        
    }

    // This gets all ratings from a user. Adapt this method for my app to load meals
    static func getUserRatings(completion: @escaping ([Meal]) -> Void) {
  
        var result: [Meal] = []
            print("user uuid" + NetworkManager.userUuid + "is empty?")

        print("user uuid: \(NetworkManager.userUuid)")
        // delete this for when i figure out my issue with async calls
        //self.userUuid = "69f51b1c-cbbe-4592-a2d0-bea4702f7458"
        
        AF.request("http://localhost:3000/ratings/user/\(NetworkManager.userUuid)")
        .validate()
        .responseDecodable(of: [User].self) { (response) in
        
            
        guard let userData = response.value else {
            print("Fetch Single User Error: \(String(describing: response.error))")
            return }
            for rating in userData[0].ratings {
                let mealName = rating.meal.mealName
                let imagePath = rating.meal.imagePath
                let ratingScore = rating.ratingScore
                let photo = FoodWebService.loadUIImageFromURL(imagePath: imagePath) // loads image from path name
                guard let cell = Meal(name: mealName, photo: photo, imagePath: imagePath, rating: ratingScore)
                else {
                    print("Meal Initialization Error: check Meal object for loop")
                    return
                }
                print("appending result")
                result.append(cell)
            }
            print("completion handler")
            completion(result)
        }
      }
    
    static func updateMealRating(mealName: String, rating: Int, imagePath: String, hasImageFile: Bool) {
        let url: String = "http://localhost:3000/ratings/meal/"
        
        let params: [String: Any] = [
            "userUuid": NetworkManager.userUuid,
            "mealName": mealName,
            "imagePath": imagePath,
            "hasImageFile": false, // defaults to false
            "ratingScore": rating
        ]

        AF.request(url, method: .put, parameters: params).responseString { (response) in
            guard response.value != nil else {
                print("Put request failed: \(String(describing: response.error))")
                return
            }
            print("Updated existing meal rating to user profile!")
        }
    }
    
    static func postMealRating(mealName: String, rating: Int, imagePath: String, hasImageFile: Bool) {
        let url: String = "http://localhost:3000/ratings/meal"
        
        let params: [String: Any] = [
            "userUuid": NetworkManager.userUuid,
            "mealName": mealName,
            "imagePath": imagePath,
            "hasImageFile": false, // defaults to false
            "ratingScore": rating
        ]

        AF.request(url, method: .post, parameters: params).responseString { (response) in
            guard response.value != nil else {
                print("Post request failed: \(String(describing: response.error))")
                return
            }
            print("Posted new meal rating to user profile!")
        }
    }
    
    // working on delete function [Meal]
    static func deleteMealRating(mealName: String) {
        let url: String = "http://localhost:3000/ratings/\(NetworkManager.userUuid)/meal/\(mealName)"
        
        let params: [String: Any] = [
            "userUuid": NetworkManager.userUuid,
            "mealName": mealName,
        ]

        AF.request(url, method: .delete, parameters: params).responseString { (response) in
            guard response.value != nil else {
                print("Delete request failed: \(String(describing: response.error))")
                return
            }
            print("Deleted meal from user profile!")
        }
    }
    
}
