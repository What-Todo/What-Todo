//
//  LoginViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    
    let segueSignedIn = "SignedIn"
    let TabBarController = "TabBarController"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.alpha = 0
    }
    
    @IBAction func loginButtonDidTouch(_ sender: Any) {
        guard
          let email = usernameTextField.text,
          let password = passwordTextField.text
          else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error, user == nil {
            self.showError("Sign in Faild")
            print("Error sign in faild")
          } else { // signed in
                Auth.auth().addStateDidChangeListener() { auth, user in
                  if user != nil {
//                    self.performSegue(withIdentifier: self.segueSignedIn, sender: nil)
                    self.usernameTextField.text = nil
                    self.passwordTextField.text = nil
                    self.transitionToHome()
                  }
                }
            print("singed in")
            self.errorLabel.alpha = 0
            }
        }
    }
    
    func showError(_ error : String) {
        errorLabel.text = error
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        
        let MainNC = storyboard?.instantiateViewController(identifier: TabBarController)
        view.window?.rootViewController = MainNC
        view.window?.makeKeyAndVisible()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
