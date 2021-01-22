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
    var imagePathToSave: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    // MARK: Autocomplete/SearchTextField
    
    @IBAction func textFieldEditingChanged(_ sender: SearchTextField) {
        
        // prints out each letter the user types (helpful for error checking)
        //print(sender.text!)
    
        FoodWebService.run(after: 3) {
            self.configureIngredientSearchTextField()
        }
    }
    
     func configureIngredientSearchTextField() {
            
        // Start visible even without user's interaction as soon as created - Default: false
        nameTextField.startVisibleWithoutInteraction = false
              
        // Set data source
        FoodWebService.getFoodSearchResults(query: self.nameTextField.text?.replacingOccurrences(of: " ", with: "") ?? "")
        self.replaceDefaultImage()

        FoodWebService.dispatchGroup.notify(queue: .main) {
            
            let searchResults = FoodWebService.searchResults
            self.nameTextField.filterStrings(searchResults)
            
        }
    }
    
    // Set default image to the text that is in the text field
    func replaceDefaultImage() -> Void {
        
        // find the correct image associated with chosen search::: NOTE THAT EVERYTHING IS IN THIS HANDLER!!!
        self.nameTextField.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            //print("Item at position \(itemPosition): \(item.title)")
            
            // set the textfield bar to the chosen item
            self.nameTextField.text = item.title
            
            // set the image.png file to image path
            let imagePath = FoodWebService.searchResultsImages[itemPosition]

            self.imagePathToSave = imagePath //NEEDED TO SEND TO DATABASE; MEALDATAMODEL updated 2021
            
            self.photoImageView.image = FoodWebService.loadUIImageFromURL(imagePath: imagePath)
        }
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
        //let photo = photoImageView.image (this is used for gallery picker photos)
        let imagePath = self.imagePathToSave
        let photo = FoodWebService.loadUIImageFromURL(imagePath: imagePath) // loads image from path name
        let rating = ratingControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, imagePath: self.imagePathToSave, rating: rating)
        
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


