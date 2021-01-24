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
        
    static var headers: HTTPHeaders = [
            "Authorization": "Bearer ",
           // "Content-Type": "application/json; charset=utf-8"
        ]

    
    // MARK: RateMyMeal REST API Calls
    
    func setAuthorizationHeaders(token: String) {
        NetworkManager.headers["Authorization"] = "Bearer " + token
        print("\(NetworkManager.headers)")
    }
    
    func postLoginCredentials(username: String, password: String, completion: @escaping (Bool) -> Void) {
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
                print("Response data \(String(describing: response.data))")

                let loginResponse = try JSONDecoder().decode(Login.self, from: result)
                
                if loginResponse.success == true {
                    // set user bearer token
                    NetworkManager.userUuid = loginResponse.userUuid!
                    NetworkManager.bearerToken = loginResponse.token!
                    self.setAuthorizationHeaders(token: NetworkManager.bearerToken)
                    print("Login Response\(loginResponse)")
                    completion(true)
                } else {
                    print("there isn't a bearer token bc the username/password was wrong")
                    completion(false)
                }
            } catch {
                print(error)
            }
        }
    }

    // This gets all ratings from a user. Adapt this method for my app to load meals
    static func getUserRatings(completion: @escaping ([Meal]) -> Void) {
        
        let url = "http://localhost:3000/ratings/user/\(NetworkManager.userUuid)"
        var result: [Meal] = []

        AF.request(url, method: .get, headers: NetworkManager.headers)
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
                result.append(cell)
            }
            completion(result)
        }
      }
    
    static func updateMealRating(mealName: String, rating: Int, imagePath: String, hasImageFile: Bool) {
        let url: String = "http://localhost:3000/ratings/meal/"
        
        let params: [String: Any] = [
            "userUuid": NetworkManager.userUuid,
            "mealName": mealName,
            "imagePath": imagePath,
            "hasImageFile": true, // defaults to false
            "ratingScore": rating
        ]

        AF.request(url, method: .put, parameters: params, headers: NetworkManager.headers).responseString { (response) in
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

        AF.request(url, method: .post, parameters: params, headers: NetworkManager.headers).responseString { (response) in
            guard response.value != nil else {
                print("Post request failed: \(String(describing: response.error))")
                return
            }
            print("Posted new meal rating to user profile!")
        }
    }
    
    // working on delete function [Meal]
    static func deleteMealRating(mealName: String) {
        let editedMealName = mealName.replacingOccurrences(of: " ", with: "%20")
        let url: String = "http://localhost:3000/ratings/\(NetworkManager.userUuid)/meal/\(editedMealName)"
        
        let params: [String: Any] = [
            "userUuid": NetworkManager.userUuid,
            "mealName": mealName,
        ]

        AF.request(url, method: .delete, parameters: params, headers: NetworkManager.headers).responseString { (response) in
            guard response.value != nil else {
                print("Delete request failed: \(String(describing: response.error))")
                return
            }
            print("Deleted meal from user profile!")
        }
    }
    
}
