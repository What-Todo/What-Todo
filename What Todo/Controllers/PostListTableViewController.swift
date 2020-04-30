//
//  PostListTableViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase


class PostListTableViewController: UITableViewController {
    
    // MARK: - Properties
    var posts: [Post] = []
    var user: User!
    var selectedCategoryKey : String = "" // updated from MainCategoryViewController > prepare()
    var postCount = 0
    
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Synchronizing Data to the Table view
        let currentUser = Auth.auth().currentUser
//        print(self.ToDoRef.child(selectedCategoryKey)) // print reference
        self.ToDoRef.child(selectedCategoryKey).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("posts") { // if posts exists
                self.ToDoRef.child(self.selectedCategoryKey).child("posts").queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
                  var newItems: [Post] = []
                    for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                      let post = Post(snapshot: snapshot) {
                        print(post.details, post.key)
                        print(currentUser!.uid)
                            newItems.append(post)
                    }
                  }
                  self.posts = newItems
                  self.tableView.reloadData()
                })
            } else { // if posts does not exists (first time)
                self.ToDoRef.child(self.selectedCategoryKey).child("posts").setValue("posts")
            }
        }

        
//        self.ToDoRef.child(selectedCategoryKey).child("posts").observe(.value, with: { snapshot in
//          print(snapshot.value as Any)
//        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    // MARK: - Button Actions
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let postsRef = Database.database().reference().child("ToDoLists").child(selectedCategoryKey).child("posts")
        
        let addPopUp = UIAlertController(title: "Post Todo",
                                         message: "Type to post Todo",
                                         preferredStyle: .alert)
        
        let currentUser = Auth.auth().currentUser
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = addPopUp.textFields?.first,
                let text = textField.text else { return }
            
            let todoPost = Post(aDetails: text,
                                completed: false,
                                anAddedByUser: currentUser!.uid) // unique user id in Authentication
            // this todo post's unique reference is set by firebase
            let todoPostRef = postsRef.childByAutoId()
            todoPostRef.setValue(todoPost.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        addPopUp.addTextField()
        
        addPopUp.addAction(saveAction)
        addPopUp.addAction(cancelAction)
        
        present(addPopUp, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell

        // Configure the cell...
        let thisPost = posts[indexPath.row]
        cell.detailsLabel?.text = thisPost.details
        
        let displayName = nameOfuid(thisPost.addedByUser)
        cell.userNameLabel?.text = displayName
        
        print(cell.detailsLabel.text as Any)
        return cell
    }
    
    func nameOfuid(_ uid: String) -> String {
        let UsersRef = Database.database().reference(withPath: "Users")
        var result: String = ""
        
        UsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as? NSDictionary
            for aUser in users! {
                print(UsersRef.child(aUser.key as! String))
                UsersRef.child(aUser.key as! String).observeSingleEvent(of: .value, with: { (userSnapshot) in
                    let value = userSnapshot.value as? NSDictionary
                    let displayName = value?["displayName"] as? String ?? "failed to obtain displayName"
                    result = displayName
                })
            }
        })
        return result
    }
    

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
