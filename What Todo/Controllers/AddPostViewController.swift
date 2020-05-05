//
//  AddPostViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 5/1/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class AddPostViewController: UIViewController {

    @IBOutlet weak var postTodoLabel: UILabel!
    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let currentUser = Auth.auth().currentUser
    let UsersRef = Database.database().reference(withPath: "Users")

    var selectedCategoryKey: String = ""
    var selectedDue: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePickerDidSelect(_ sender: Any) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yy"
        let day = dateFormatter.string(from: datePicker.date)
        dateFormatter.timeStyle = .short
        let time = dateFormatter.string(from: datePicker.date)
        
        selectedDue = day + " " + time
    }
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        let postsRef = Database.database().reference().child("ToDoLists").child(selectedCategoryKey).child("posts")
        let todoPost = Post(aDetails: detailsTextField.text!,
                            completed: false,
                            anAddedByUser: currentUser!.uid,
                            aDue: self.selectedDue) // unique user id in Authentication
        // this todo post's unique reference is set by firebase
        let todoPostRef = postsRef.childByAutoId()
        todoPostRef.setValue(todoPost.toAnyObject())
        incrementMadeCounter()

        navigationController?.popViewController(animated: true)
    }
    
    func incrementMadeCounter() {
        UsersRef.child(currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if snapshot.hasChild("madeCounter") {
                let madeCounter = value?.value(forKey: "madeCounter") as! Int
                self.UsersRef.child(self.currentUser!.uid).updateChildValues(["madeCounter" : madeCounter + 1])
            } else {
                self.UsersRef.child(self.currentUser!.uid).child("madeCounter").setValue(1)
            }
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
