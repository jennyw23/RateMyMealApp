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
        static let rating = "rating"
    }
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    //MARK: Archiving Paths
    
       static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
       static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Initialization

    init?(name: String, photo: UIImage?, rating: Int){
        
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
        self.rating = rating
    }
    
    //MARK: NSCoding
    
    func encode(with coder: NSCoder) {

        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(photo, forKey: PropertyKey.photo)
        coder.encode(rating, forKey: PropertyKey.rating)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {

        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
                   os_log("Unable to decode the name for a Meal object", log: OSLog.default, type: .debug)
                   return nil
               }
    
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)

        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating)
    }
    
}


