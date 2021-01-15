//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Jenny Wang on 8/5/20.
//  Copyright © 2020 Jenny Wang. All rights reserved.
//

import UIKit
import os.log
import SearchTextField
import Alamofire

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: Properties
    //@IBOutlet weak var nameTextField: SearchTextField!
    @IBOutlet weak var nameTextField: SearchTextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on stype of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
            
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller")
        }
    }
    
    /*
     This value is either passed by 'MealTableViewController' in 'prepare(for:sender:)' or constructed as part of adding a new meal.
     */
    var meal: Meal?
    var ingredientsList: [String] = []
    var ingredientsImages: [String] = []
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postMeal(mealName: "water")
        postMeal(mealName: "onion")
        postRating(userUuid: "69f51b1c-cbbe-4592-a2d0-bea4702f7458", mealUuid: "5c01e62f-981d-4d3e-8dc4-911c04b34767", ratingScore: 3)
        getMeals()
        //getUserJSONData()
        //getSingleUser(userUuid: "f4475484-b5dc-4e7d-8ae3-4ff5b1bb80c0")
        
        //handle the text field's user input through delegate callbacks
        nameTextField.delegate = self

        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        //Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }

    // MARK: Autocomplete
    
    // Function that tells you how much time to wait in between calls to API
    
    func run(after seconds: Int, completion: @escaping () -> Void) {
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
    // Set default image to the text that is in the text field
    func replaceDefaultImage()-> Void {
        
        // find the correct image associated with chosen search::: NOTE THAT EVERYTHING IS IN THIS HANDLER!!!
        self.nameTextField.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // set the textfield bar to the chosen item
            self.nameTextField.text = item.title
            
            // set the image.png file to image path
            let imagePath = self.ingredientsImages[itemPosition]
            print(imagePath)
            
            // save the full URL image path
            let urlString = "https://spoonacular.com/cdn/ingredients_100x100/\(imagePath)"
             
            guard let url = URL(string: urlString) else {
                print("Error turning url into URL type...")
                return
            }
           
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            
            self.photoImageView.image = UIImage(data: data!)
        }
    }
    
    // 5 - configure ingredient search text field
     func configureIngredientSearchTextField() {
            
        // Start visible even without user's interaction as soon as created - Default: false
        nameTextField.startVisibleWithoutInteraction = false
              
        // Set data source
        getRapidAPI(query: self.nameTextField.text?.replacingOccurrences(of: " ", with: "") ?? "")

        dispatchGroup.notify(queue: .main) {
            let autocompleteList = self.ingredientsList
            //print("witihin the configureSearch function \(autocompleteList)")
            self.nameTextField.filterStrings(autocompleteList)
        }
    }
    
    fileprivate func getRapidAPI(query: String) -> Void {
        dispatchGroup.enter()

        let headers = [
            "x-rapidapi-key": "6080c0f264msh94f513bc32fa86dp1a25efjsn099feae4e8df",
            "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
        ]
        let urlString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/autocomplete?query=\(query)&number=10"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                guard let ingredientData = data else{
                    print("Error with getting json data")
                    return
                }
                DispatchQueue.main.async {
                    if let result = self.jsonToList(apiData: ingredientData) {
                        let ingredients = result.ingredients
                        let images = result.images

                        self.ingredientsList = ingredients
                        self.ingredientsImages = images
                        //print("inside dispatch queue: \(self.ingredientsList)")
                        
                        self.dispatchGroup.leave()
                    }
                }
                return
            }
        })
        dataTask.resume()
        
        self.replaceDefaultImage()
    }
    
    @IBAction func textFieldEditingChanged(_ sender: SearchTextField) {
        
        // prints out each letter the user types (helpful for error checking)
        //print(sender.text!)
    
        // print("Before running timer to call spoonacular API")
        run(after: 4) {
            self.configureIngredientSearchTextField()
        }
    }
    
    func jsonToList(apiData: Data) -> (ingredients: [String], images: [String])? {
        var ingredientsList: [String] = []
        var ingredientsImage: [String] = []
        
        let ingredients: [Food] = try! JSONDecoder().decode([Food].self, from: apiData)
        for ingredient in ingredients {
            //print("ingredient name " + ingredient.name)
            // print("adding image"+ingredient.image)

            ingredientsList.append(ingredient.name)
            ingredientsImage.append(ingredient.image)
        }
        return (ingredientsList, ingredientsImage)
    }
    
    struct Food: Decodable {
        let name: String
        let image: String
    }

    
    //MARK: UITextFieldDelegate
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }

    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    //MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating)
        
    }
    
    //MARK: Actions

    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard
        nameTextField.resignFirstResponder()
        
        //UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        //Only allows photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary
        
        //Make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState(){
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
   
    
}

extension MealViewController {
    
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
    
    func getSingleUser(userUuid: String) {
        //let myUuid = "f4475484-b5dc-4e7d-8ae3-4ff5b1bb80c0"
        AF.request("http://localhost:3000/users/\(userUuid)")
        .validate()
        .responseDecodable(of: User.self) { (response) in
          guard let userData = response.value else {
            print("FetchSingerUser Error: \(String(describing: response.error))")
            return }
            print("User userUuid Meals: ")
            for rating in userData.ratings {
                print(rating.meal.mealName)
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
