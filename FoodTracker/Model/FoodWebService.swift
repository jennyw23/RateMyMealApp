//
//  FoodWebService.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/21/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import UIKit

class FoodWebService {
    
    static var searchResults: [String] = []
    static var searchResultsImages: [String] = []

    static let dispatchGroup = DispatchGroup()
    
    static let headers = [
        "x-rapidapi-key": "6080c0f264msh94f513bc32fa86dp1a25efjsn099feae4e8df",
        "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    ]

    // Function that tells you how much time to wait in between calls to API
    static func run(after seconds: Int, completion: @escaping () -> Void) {
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
    // MARK: Spoonacular API Calls
    
    static func loadUIImageFromURL(imagePath: String) -> UIImage? {
        // set the image.png file to image path
        let imagePath = imagePath
        
        // create default "no.png" in case image path does not exist. We use ! becaues it definitely exists
        let defaultURL = URL(string: "https://spoonacular.com/cdn/ingredients_100x100/no.png")!
        
        // save the full URL image path
        let urlString = "https://spoonacular.com/cdn/ingredients_100x100/\(imagePath)"
         
        guard let url = URL(string: urlString) else {
            print("Error turning url into URL type...Setting to default image.")
            let data = try! Data(contentsOf: defaultURL)
            return UIImage(data: data)
        }
       
        guard let data = try? Data(contentsOf: url) else {
            print("Error converting url contents to data. Seeting to default image")
            let data = try! Data(contentsOf: defaultURL)
            return UIImage(data: data)
        } //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        
        return UIImage(data: data)
    }
    
    static func getFoodSearchResults(query: String) -> Void {
        
       
        let urlString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/autocomplete?query=\(query)&number=10"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = FoodWebService.headers
        
        // Enter dispatch group for food autocomplete search
        FoodWebService.dispatchGroup.enter()
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                guard let ingredientData = data else{
                    print("Error getting json data from Spoonacular API")
                    return
                }
                DispatchQueue.main.async {
                    
                    FoodWebService.updateSearchResults(searchData: ingredientData)
                    FoodWebService.dispatchGroup.leave()
                    
                    }
                }
                return
            })
        
        dataTask.resume()
    }
    
    static func updateSearchResults(searchData: Data) {
        
        let searchList: [Food] = try! JSONDecoder().decode([Food].self, from: searchData)
        
        // reset previous search results before updating with new search
        FoodWebService.searchResults = []
        FoodWebService.searchResultsImages = []
        
        for result in searchList {

            FoodWebService.searchResults.append(result.mealName)
            FoodWebService.searchResultsImages.append(result.mealImage)

        }
    } 
}

