//
//  AddCategoryViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/29/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class AddCategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var newCategoryLabel: UILabel!
    @IBOutlet weak var modePickerView: UIPickerView!
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var joinCategoryLabel: UILabel!
    @IBOutlet weak var joinKeyTextField: UITextField!
    
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")
    let mainNavigationController = "MainNC"
    var categoryKey: String = ""
    let pickerData: [String] = ["Cooperative", "Competitive", "Private"]
    var mode: String = "Cooperative"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.modePickerView.delegate = self
        self.modePickerView.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        mode = pickerData[row]
        return pickerData[row]
    }
    
    @IBAction func createButtonDidTouch(_ sender: Any) {
        let currentUser = Auth.auth().currentUser
        
        let category = Category(aName: categoryNameTextField!.text!,
                                anAddedByUser: currentUser!.uid,
                                aMode: mode,
                                aMembers: [currentUser!.uid])
        let categoryRef = self.ToDoRef.childByAutoId()
        categoryRef.setValue(category.toAnyObject())
        self.transitionToHome()
    }
    
    @IBAction func joinButtonDidTouch(_ sender: Any) {
        let currentUser = Auth.auth().currentUser
        categoryKey = joinKeyTextField!.text!
        let catRef = ToDoRef.child(categoryKey)
        
        // let userID = Auth.auth().currentUser?.uid
        
        catRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.key == self.categoryKey {
                
                // Get user value
                let value = snapshot.value as? NSDictionary
                var members = value?.value(forKey: "members") as! [String]
                // append current user
                members.append(currentUser!.uid)
                // update members with current user id
                catRef.updateChildValues(["members": members])
                
            } else {
                print("invalid key is entered in joining category")
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        self.transitionToHome()
    }

    func transitionToHome() {
        let MainNC = storyboard?.instantiateViewController(identifier: mainNavigationController)
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

