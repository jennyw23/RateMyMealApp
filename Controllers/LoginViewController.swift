//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by Jenny Wang on 1/19/21.
//  Copyright © 2021 Jenny Wang. All rights reserved.
//

import UIKit
import os.log

class LoginViewController: UIViewController {
    
    @IBOutlet weak var LoginFailedPopUp: UILabel!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    let user = NetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        LoginFailedPopUp.isHidden = true
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        let username = UsernameTextField.text
        let password = PasswordTextField.text
        
        if (UsernameTextField.text == "" || PasswordTextField.text == "") {
            return
        } else {
            self.user.postLoginCredentials(username: username!, password: password!, completion: { response in
                print(response)
                
                if response == true {
                    self.performSegue(withIdentifier: "LoggedIn", sender: self)
                } else {
                    
                    self.LoginFailedPopUp.isHidden = false

                    FoodWebService.run(after: 3, completion: {
                        self.LoginFailedPopUp.isHidden = true
                    })
                }
            })
        }
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
     //note: I ADDED THIS IN FOR TESTING ON 1/21/2021
        if segue.identifier == "LoggedIn" {
                    print("logged in segue")
            let destinationController = segue.destination as! MealViewController
                    destinationController.helloText = helloTextField.text
                }
    }
    */

}
