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
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!

    let user = NetworkManager()

    var imageView: UIImageView = {
            let imageView = UIImageView(frame: .zero)
            imageView.image = UIImage(named: "food_background.jpg")
            imageView.contentMode = .scaleToFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        view.insertSubview(imageView, at: 0)
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: view.topAnchor),
                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        self.view.bringSubviewToFront(self.UsernameTextField)
        self.view.bringSubviewToFront(self.PasswordTextField)    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        let username = UsernameTextField.text
        let password = PasswordTextField.text
        
        if (username == "" || password == "") {
            return
        } else {
            self.user.postLoginCredentials(username: username!, password: password!, completion: {
                self.performSegue(withIdentifier: "LoggedIn", sender: self)
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
