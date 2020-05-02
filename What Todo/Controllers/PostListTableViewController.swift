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
    @IBOutlet var postTableView: UITableView!
    var posts: [Post] = []
    var users: [User] = []
    var selectedCategoryKey : String = "" // updated from prepare()
    
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")
    let UsersRef = Database.database().reference(withPath: "Users")
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Synchronizing Data to the Table view
//        print(self.ToDoRef.child(selectedCategoryKey)) // print reference
        updatePosts()
//        orderChecked()
        self.tableView.reloadData()
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let AddPostVC = segue.destination as! AddPostViewController
        // pass selectedCategoryKey to AddPostVC
        AddPostVC.selectedCategoryKey = self.selectedCategoryKey
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell

        // detailsLabel
        let thisPost = posts[indexPath.row]
        cell.detailsLabel?.text = thisPost.details

        // dispalyName
        UsersRef.child(thisPost.addedByUser).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            cell.userNameLabel!.text = value?["displayName"] as? String ?? "failed"
            })
        
        // due
        cell.dueLabel!.text = thisPost.due

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
      let selected = posts[indexPath.row]
      let toggledCompletion = !selected.completed
      toggleChecked(cell, isCompleted: toggledCompletion)
      selected.ref?.updateChildValues([
        "completed": toggledCompletion
        ])
    }
    
    func toggleChecked(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.textLabel?.textColor = .gray
        
      if isCompleted {
//        cell.accessoryType = .checkmark
//        cell.detailsTextLabel?.textColor = .gray
//        cell.userNameLabel?.textColor = .gray
        cell.contentView.backgroundColor = UIColor.lightText

      } else {
        cell.contentView.backgroundColor = UIColor.clear
//        cell.accessoryType = .none
//        cell.userNameLabel?.textColor = .black
//        cell.detailsTextLabel?.textColor = .black
      }
    }
    
    func updatePosts() {
        self.ToDoRef.child(selectedCategoryKey).observeSingleEvent(of: .value) { (snapshot) in // look category
            if snapshot.hasChild("posts") { // if posts exists
                self.ToDoRef.child(self.selectedCategoryKey).child("posts").queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
                  var newItems: [Post] = []
                    print("snapshot in updatePosts: ")
                    print(snapshot as Any)
                    for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                      let post = Post(snapshot: snapshot) {
//                        print(post.details, post.key)
//                        print(currentUser!.uid)
                        if !post.completed {
                            newItems.append(post)
                        }
                    }
                  }
                  self.posts = newItems
                    self.tableView.reloadData()
                })
            } else { // if posts does not exists (first time)
                self.ToDoRef.child(self.selectedCategoryKey).child("posts").setValue("posts")
            }
        }
    }
    
    func orderChecked() {
        self.ToDoRef.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
          var newItems: [Post] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let post = Post(snapshot: snapshot) {
              newItems.append(post)
            }
          }
          
          self.posts = newItems
          self.tableView.reloadData()
        })
    }
    
    func getDisplayName(_ post: Post) -> String {
        var result: String = ""
        // get dispalyName
        UsersRef.child(post.addedByUser).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            result = value?.value(forKey: "displayName") as? String ?? ""
            })
        return result
    }
    
    func getSelectedCatKey() -> String {
        return self.selectedCategoryKey
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
