//
//  SignUpViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/25/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SignUpViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: Proparties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    let UserRef = Database.database().reference(withPath: "Users")
    var locationManager = CLLocationManager()
    var userLocation: String = "Earth"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        locationSetUp()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Button Actions

    @IBAction func signUpButtonDidTouch(_ sender: Any) {
        let error = validateFields()
        if error != nil {
            // show error message
            self.showError(error!)
        } else { // create user if no error
            self.addUser()
        }
        
    }
    
    // Check the fields and validata that the data is correct.
    func validateFields() -> String? {
        
        // check if all fields are filled in.
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            confPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {

            return "Please Fill All Contents"
        } else if passwordTextField.text != confPasswordTextField.text {
            return "Password is not matched"
        }
        return nil
    }
    
    func addUser() {
        // Get the email and password as supplied by the user and create user account
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            if error != nil {
                self.showError("Error creating user")
                print("Sign up failed")
            } else { // add user info
                // add user info
                self.addUserInfo(authResult!)
                self.dismiss(animated: true, completion: nil)
                print(authResult?.user.email as Any)
            }
        }
    }
    
    func addUserInfo(_ newUser: AuthDataResult) {
        let usersRef = Database.database().reference().child("Users")
        var user = User(aUserId: newUser.user.uid, aEmail: newUser.user.email!, aName: nameTextField.text!, aDisplayName: displayNameTextField.text!)
        if CLLocationManager.locationServicesEnabled() {
            switchAuthorizationStatus(newUser)
        }
        user.setLocation(newLocation: self.userLocation)
        
        let userRef = usersRef.child(newUser.user.uid)
        userRef.setValue(user.toAnyObject())
    }
    
    func showError(_ error : String) {
        errorLabel.text = error
        errorLabel.alpha = 1
    }
    
    func locationSetUp() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()

    }
    
    func switchAuthorizationStatus(_ newUser: AuthDataResult) {
        print(CLLocationManager.authorizationStatus() as Any)
        switch(CLLocationManager.authorizationStatus())
         {
        case .authorizedAlways, .authorizedWhenInUse:
             print("Authorize.")
             let latitude: CLLocationDegrees = (locationManager.location?.coordinate.latitude)!
             let longitude: CLLocationDegrees = (locationManager.location?.coordinate.longitude)!
             let location = CLLocation(latitude: latitude, longitude: longitude)
             CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                 if error != nil {
                     return
                 }else if let country = placemarks?.first?.country,
                     let city = placemarks?.first?.locality {
                    self.UserRef.child(newUser.user.uid).updateChildValues(["location": city + ", " + country])
                 }
                 else {
                    print("else")
                 }
             })
             break

         case .notDetermined:
             print("Not determined.")
             break

         case .restricted:
             print("Restricted.")
             break

         case .denied:
             print("Denied.")
         }
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
