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
    
    /*
    var userRatingsAndMeals: [(String, String)] = []
    
    init(userUuid: String){
        self.userUuid = userUuid
    }

    func fetchSingleUser() {
        let myUuid = "f4475484-b5dc-4e7d-8ae3-4ff5b1bb80c0"
        let request = AF.request("http://localhost:3000/users/\(myUuid)")

        request.responseDecodable(of: User.self) { (response) in
          guard let userData = response.value else { return }
          print(userData.all[0].title)
        }
       /*
        let userRatingsData: [UserInfo.Rating] = userData.ratings
        
        for i in 0...userRatingsData.count {

            let mealName: String = userRatingsData[i].meal.mealName
            let ratingScore: String = userRatingsData[i].ratingScore
            
            self.userRatingsAndMeals += [(mealName, ratingScore)]
        }
*/
      }
    
    func getFood() -> Void {
        let urlString = "http://localhost:3000/users/\(userUuid)"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        let headers = ["bearer-token": "insertbearertoken"]
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                guard let jsonData = data else{
                    print("Error with getting json data")
                    return
                }
                if let userData = try JSONDecoder().decode(UserInfo.self, from: jsonData)
                    let userRatingsData: [UserInfo.Rating] = userData.ratings
                    
                    for i in 0...userRatingsData.count {

                        let mealName: String = userRatingsData[i].meal.mealName
                        let ratingScore: String = userRatingsData[i].ratingScore
                        
                        self.userRatingsAndMeals += [(mealName, ratingScore)]
                    }
            }
            return self.userRatingsAndMeals
        })
        dataTask.resume()
        
    }
    
    
    extension User: Decodable {
        var id: Int
        var userUuid: String
        var username: String
        var password: String
        var email: String
        var createdAt: String
        var updatedAt: String
        var ratings: [Rating]
        
        
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
    }

    enum RateMyMealAPIError: Error {
        case noDataAvailable
        case cannotLoadDatabase
    }
    */
}
