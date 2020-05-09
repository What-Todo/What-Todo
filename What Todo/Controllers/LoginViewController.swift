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

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    
    let segueSignedIn = "SignedIn"
    let TabBarController = "TabBarController"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.alpha = 0
        lineTextField(emailTextField)
        lineTextField(passwordTextField)
    }
    
    func lineTextField(_ textField: UITextField) {
        
        // Create the bottom layer
        let bottomLine = CALayer()
                
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor
        
        // Add the line to the text field
        textField.layer.addSublayer(bottomLine)
        
        // Change color of placeholder text to be darker
        textField.attributedPlaceholder = NSAttributedString(string: textField.attributedPlaceholder?.string ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    @IBAction func loginButtonDidTouch(_ sender: Any) {
        guard
          let email = emailTextField.text,
          let password = passwordTextField.text
          else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error, user == nil {
            self.showError("Sign in Failed")
            print("Error sign in failed")
          } else { // signed in
                Auth.auth().addStateDidChangeListener() { auth, user in
                  if user != nil {
//                    self.performSegue(withIdentifier: self.segueSignedIn, sender: nil)
                    self.emailTextField.text = nil
                    self.passwordTextField.text = nil
                    self.transitionToHome()
                  }
                }
            print("signed in")
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
