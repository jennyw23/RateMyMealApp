//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Jenny Wang on 8/17/20.
//  Copyright © 2020 Jenny Wang. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
     
    var meals: [Meal] = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        // Call asynchronous loadMeals and set a constant savedMeals to the meals we load from database
        loadMeals(completion: { response in

            let savedMeals = response
            
            if (savedMeals?.count ?? 0) > 0 {
                self.meals = savedMeals ?? [Meal]()
            } else{
                //self.loadSampleMeals()
                print("The user currently has no saved meals")
            }
            
            // Update the UI at the end of this asynchronous call to loadMeals
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "MealTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            NetworkManager.deleteMealRating(mealName: meals[indexPath.row].name) // deletes from database
            meals.remove(at: indexPath.row)
            
            saveMeals(action: .updateExisting)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? ""){
            
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
                
            guard let selectedMealCell = sender as? MealTableViewCell else{
                fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else{
                fatalError("The selected cell is not being displayed by the table")
                }
                
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Private Methods
    
    private func loadSampleMeals(){
        let defaultImagePath = "no.png"
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        let photo4 = UIImage(named: "meal4")
        
        guard let meal1 = Meal(name: "Burger", photo: photo1, imagePath: defaultImagePath, rating: 4) else{
            fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = Meal(name: "Coffee", photo: photo2, imagePath: defaultImagePath, rating: 2) else{
            fatalError("Unable to instantiate meal2")
        }
        guard let meal3 = Meal(name: "Pizza", photo: photo3, imagePath: defaultImagePath, rating: 5) else{
            fatalError("Unable to instantiate meal3")
        }
        guard let meal4 = Meal(name: "Sandwich", photo: photo4, imagePath: defaultImagePath, rating: 4) else{
            fatalError("Unable to instantiate meal4")
        }
        
        meals += [meal1, meal2, meal3, meal4]
    }
    
    private enum Action {
        case addNew
        case updateExisting
    }
    
    private func saveMeals(action: Action) {

        switch action {
        case .addNew:
            do {
                for meal in meals {
                     let hasImageFile: Bool = true
                    /* build an if statement to determine if the food item has an image file
                     if (/*some logic that makes sense - jenny 1/17/21*/ meal != nil) {
                         hasImageFile = false
                     } else {
                         hasImageFile = true
                     }
                     */
                    
                    NetworkManager.postMealRating(mealName: meal.name, rating: meal.rating, imagePath: meal.imagePath ?? "no.png", hasImageFile: hasImageFile)
                }
               
                os_log("Meals successfully saved. Case: .addNew ", log: OSLog.default, type: .debug)
            } catch {
                os_log("error: %@", log: .default, type: .error, String(describing: error))
            }
        case .updateExisting:
            do {
                for meal in meals {
                     let hasImageFile: Bool = false
                    /* build an if statement to determine if the food item has an image file
                     if (/*some logic that makes sense - jenny 1/17/21*/ meal != nil) {
                         hasImageFile = false
                     } else {
                         hasImageFile = true
                     }
                     */
                    
                    NetworkManager.updateMealRating(mealName: meal.name, rating: meal.rating, imagePath: meal.imagePath ?? "no.png", hasImageFile: hasImageFile)
                }
                os_log("Meals successfully updated. Case: .updateExisting ", log: OSLog.default, type: .debug)
            } catch {
                os_log("error: %@", log: .default, type: .error, String(describing: error))
            }
        }
    }
    

            
    //MARK: Actions
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                // Update an existing meal.
                meals[selectedIndexPath.row] = meal
                print(meal)
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                // Save the meals.
                saveMeals(action: .updateExisting)
                print("meals saved")
            }
            else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                // Save the meals.
                saveMeals(action: .addNew)
            }
        }
    }
    
    private func loadMeals(completion: @escaping ([Meal]?) -> ()) {

        print("Bearer Token" + NetworkManager.bearerToken)
        
        // load meals from MySQL database
        NetworkManager.getUserRatings { (catchingvalue: [Meal]) in
                completion(catchingvalue)
            }
    }

}

