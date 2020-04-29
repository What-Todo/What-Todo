//
//  AddCategoryViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/29/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class AddCategoryViewController: UIViewController {

    @IBOutlet weak var newCategoryLabel: UILabel!
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var joinCategoryLabel: UILabel!
    @IBOutlet weak var joinKeyTextField: UITextField!
    
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButtonDidTouch(_ sender: Any) {
        let currentUser = Auth.auth().currentUser
        
        let category = Category(aName: categoryNameTextField!.text!,
                                anAddedByUser: currentUser!.uid,
                                aMembers: [currentUser!.uid])
        let categoryRef = self.ToDoRef.childByAutoId()
        categoryRef.setValue(category.toAnyObject())
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinButtonDidTouch(_ sender: Any) {
        let currentUser = Auth.auth().currentUser
        let categoryKey = joinKeyTextField!.text
        let catRef = ToDoRef.child(categoryKey!)
        var members: [String] = []
        
        self.ToDoRef.observe(.value, with: { snapshot in
            
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let category = Category(snapshot: snapshot) {
                if category.key == categoryKey {
                    // get category's member list
                    members = category.members
                    members.append(currentUser!.uid)
                    // update members with current user id
                    catRef.updateChildValues(["members": members])
                    break
                }
            }
          }
        })
        self.dismiss(animated: true, completion: nil)
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
