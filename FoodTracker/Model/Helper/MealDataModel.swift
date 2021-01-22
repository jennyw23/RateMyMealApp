//
//  MealDataModel.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/14/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
// NOTE: I MADE UNNECESSARY CHANGES TO KEEP THE APP WORKING. LATER I SHOULD TRY TO IMPLEMENT CODABLE TO REPLACE NSCODING, BUT FOR NOW IT'S FINE

import UIKit
import OSLog

class MealDataModel: Codable {
    

    //MARK: Properties
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case photo = "photo"
        case spoonacularPhoto = "spoonacularPhoto"
        case rating = "rating"
    }
    
    var name: String
    var photo: UIImage?
    var spoonacularPhoto: String?
    var rating: Int
    
    //MARK: Archiving Paths
    
       static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
       static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    

    //MARK: Initialization
     
    init?(name: String, photo: UIImage?, spoonacularPhoto: String?, rating: Int) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
         
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.spoonacularPhoto = spoonacularPhoto
        self.rating = rating
    }
    
    //MARK: Codable
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        
        try container.encode(spoonacularPhoto, forKey: .spoonacularPhoto)
        try container.encode(rating, forKey: .rating)
        
        let imageData = try NSKeyedArchiver.archivedData(withRootObject: photo, requiringSecureCoding: false)
            try container.encode(imageData, forKey: .photo)
        
    }
    
    required convenience init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)
        
        let spoonacularPhoto = try? container.decode(String.self, forKey: .spoonacularPhoto)
        let rating = try container.decode(Int.self, forKey: .rating)
        
        let photoData = try container.decode(Data.self, forKey: .photo)
        let photo = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(photoData) as? UIImage ?? UIImage(named: "meal1")
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, spoonacularPhoto: spoonacularPhoto, rating: rating)!
    }

}
