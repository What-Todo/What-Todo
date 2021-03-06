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
    var cellColor: Int = 0
    
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")
    let UsersRef = Database.database().reference(withPath: "Users")
    let StorageRef = Storage.storage().reference()

    let currentUser = Auth.auth().currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Synchronizing Data to the Table view
        setNavigationBar()
        updatePosts()
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
        AddPostVC.cellColor = self.cellColor
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
        
        // get image
        StorageRef.child(thisPost.addedByUser).downloadURL { (url, error) in
            let userProfilePhotoRef = self.StorageRef.child(thisPost.addedByUser)
            userProfilePhotoRef.getData(maxSize: 1024 * 1024) { (data, error) in
                if let error = error { return } else {
                    let image = UIImage(data: data!)
                    cell.profileImageView.image = image
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let selected = posts[indexPath.row]
      let toggledCompletion = !selected.completed
      selected.ref?.updateChildValues([
        "completed": toggledCompletion
        ])
        setCompletedBy(selected)
        addToRecentActivities(selected)
        addToNotifications(selected)
        incrementCompletedCounter()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let deletingPost = posts[indexPath.row]
            deletingPost.ref?.removeValue()
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func updatePosts() {
        self.ToDoRef.child(selectedCategoryKey).observe(.value, with: { (snapshot) in // look category
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
        })
    }
    
    func setCompletedBy(_ completedPost: Post) {
        self.ToDoRef.child(selectedCategoryKey).child("posts").child(completedPost.key).updateChildValues(["addedByUser": self.currentUser!.uid])
    }
    
    func addToRecentActivities(_ completedPost: Post) {
        UsersRef.child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if snapshot.hasChild("recentActivities") {
                var recentActivities = value?.value(forKey: "recentActivities") as! [Any]
                // append completedPost
                recentActivities.append(completedPost.toAnyObject())
                // update members with current user id
                self.UsersRef.child(self.currentUser!.uid).updateChildValues(["recentActivities": recentActivities])
            } else {
                self.UsersRef.child(self.currentUser!.uid).child("recentActivities").setValue([completedPost.toAnyObject()])
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addToNotifications(_ completedPost: Post) {
        // get members
        ToDoRef.child((completedPost.ref?.parent?.parent?.key)!).observeSingleEvent(of: .value) { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let members = value?.value(forKey: "members") as! [String]
            let mode = value?.value(forKey: "mode") as! String
            for member in members {
                self.addNotificationsToMember(snapshot, completedPost, member, mode)
            }
        }
    }
    
    func addNotificationsToMember(_ snapshot: DataSnapshot, _ completedPost: Post, _ member: String, _ mode: String) {
        UsersRef.child(member).observeSingleEvent(of: .value) { (memberSnap) in
            if memberSnap.hasChild("notifications") {
                self.UsersRef.child(member).child("notifications").observeSingleEvent(of: .value) { (notificationSnap) in
                    if notificationSnap.hasChild(mode) {
                        let value = notificationSnap.value as? NSDictionary
                        var notificationsOfMode = value?.value(forKey: mode) as! [Any]
                        notificationsOfMode.append(completedPost.toAnyObject())
                        self.UsersRef.child(member).child("notifications").updateChildValues([mode: notificationsOfMode])
                    } else {
                        self.UsersRef.child(member).child("notifications").child(mode).setValue([completedPost.toAnyObject()])
                    }
                }
            } else {
                self.UsersRef.child(member).child("notifications").child(mode).setValue([completedPost.toAnyObject()])
            }
        }
    }
    
    
    
    func setNavigationBar() {
        // set title
        ToDoRef.child(selectedCategoryKey).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.navigationItem.title = value?.value(forKey: "details") as! String
        }
        // set color
        switch cellColor {
        case 0:
            self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 252/255, green: 243/255, blue: 173/255, alpha: 1)
            break
        case 1:
            self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 248/255, green: 209/255, blue: 235/255, alpha: 1)
            break
        case 2:
            self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 192/255, green: 245/255, blue: 243/255, alpha: 1)
            break
        default:
            break
        }
    }
    
    func incrementCompletedCounter() {
        UsersRef.child(currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if snapshot.hasChild("completedCounter") {
                var completedCounter = value?.value(forKey: "completedCounter") as! Int
                self.UsersRef.child(self.currentUser!.uid).updateChildValues(["completedCounter" : completedCounter + 1])
            } else {
                self.UsersRef.child(self.currentUser!.uid).child("completedCounter").setValue(1)
            }
        }
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


