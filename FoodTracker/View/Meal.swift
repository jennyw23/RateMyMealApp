//
//  Meal.swift
//  FoodTracker
//
//  Created by Jenny Wang on 8/15/20.
//  Copyright © 2020 Jenny Wang. All rights reserved.
//
import UIKit
import os.log

class Meal: NSObject, NSCoding {
    
    //MARK: Properties
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let imagePath = "imagePath"
        static let rating = "rating"
    }
    
    var name: String
    var photo: UIImage?
    var imagePath: String?
    var rating: Int
    
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?, imagePath: String?, rating: Int){
        
        // the name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else{
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.imagePath = imagePath
        self.rating = rating
    }
    
    //MARK: NSCoding
    
    func encode(with coder: NSCoder) {

        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(imagePath, forKey: PropertyKey.imagePath)
        coder.encode(photo, forKey: PropertyKey.photo)
        coder.encode(rating, forKey: PropertyKey.rating)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {

        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
                   os_log("Unable to decode the name for a Meal object", log: OSLog.default, type: .debug)
                   return nil
               }
    
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let imagePath = aDecoder.decodeObject(forKey: PropertyKey.imagePath) as? String

        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)

        
        // Must call designated initializer.
        self.init(name: name, photo: photo, imagePath: imagePath, rating: rating)
    }
    
    func toString() {
        print("Name: \(self.name), Photo: \(String(describing: self.photo ?? UIImage(named: "meal1"))), Image Path: \(String(describing: self.imagePath)), Rating: \(self.rating)")
    }
    
}
