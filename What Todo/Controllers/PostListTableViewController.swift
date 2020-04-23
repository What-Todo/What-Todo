//
//  PostListTableViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

private let ToDoRef = Database.database().reference(withPath: "ToDoLists")

class PostListTableViewController: UITableViewController {
    
    // MARK: - Properties
    var posts: [Post] = []
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let catRef = Database.database().reference().child("ToDoLists").child("project a").child("posts") // category reference ToDoLists > project a > posts (project a) should be variable
        
        let addPopUp = UIAlertController(title: "Post Todo",
                                         message: "Type to post Todo",
                                         preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = addPopUp.textFields?.first,
                let text = textField.text else { return }
            
            let todoPost = Post(aDetails: text,
                                completed: false,
                                anAddedByUser: "self.user.name",
                                timestamp: "timestamp")
            // this todo post's unique reference is set by firebase
            let todoPostRef = catRef.childByAutoId()
            todoPostRef.setValue(todoPost.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        addPopUp.addTextField()
        
        addPopUp.addAction(saveAction)
        addPopUp.addAction(cancelAction)
        
        present(addPopUp, animated: true, completion: nil)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
