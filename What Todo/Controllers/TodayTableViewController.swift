//
//  TodayTableViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 5/1/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class TodayTableViewController: UITableViewController {
    
    @IBOutlet var todayTableView: UITableView!
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")
    let UsersRef = Database.database().reference(withPath: "Users")
    let currentUser = Auth.auth().currentUser
    
    var categories: [Category] = []
    var todaysPosts: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        setNavigationBar()
        for category in categories {
            getTodayPosts(category.key)
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todaysPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTableViewCell", for: indexPath) as! TodayTableViewCell
        
        // detailsLabel
        let thisPost = todaysPosts[indexPath.row]
        cell.detailsLabel?.text = thisPost.details
        
        // dispalyName
        UsersRef.child(thisPost.addedByUser).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            cell.userNameLabel!.text = value?["displayName"] as? String ?? "failed"
        })
        
        // display category name
        ToDoRef.child((thisPost.ref?.parent?.parent?.key)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            cell.categoryNameLabel!.text = value?["details"] as? String ?? "failed"
        })
        
        // due
        cell.dueLabel!.text = thisPost.due
        
        return cell
    }
    
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        let selected = todaysPosts[indexPath.row]
//        let toggledCompletion = !selected.completed
//        selected.ref?.updateChildValues([
//            "completed": toggledCompletion
//        ])
//        addToRecentActivities(selected)
//        addToNotifications(selected)
//        incrementCompletedCounter()
//    }
    
    func getTodayPosts(_ catKey: String) {
        self.ToDoRef.child(catKey).observeSingleEvent(of: .value) { (snapshot) in // look category
            if snapshot.hasChild("posts") { // if posts exists
                self.ToDoRef.child(catKey).child("posts").queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
                    print("snapshot in updatePosts: ")
                    print(snapshot as Any)
                    for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot,
                            let post = Post(snapshot: snapshot) {
                            if self.checkDate(post.due) && !post.completed {
                                self.todaysPosts.append(post)
                            }
                        }
                    }
                    self.tableView.reloadData()
                })
            } else { // if posts does not exists (first time)
            }
        }
    }
    
    func checkDate(_ postDue: String) -> Bool {
        let dateFormat = "MM/dd/yy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        let today = dateFormatter.string(from: Date()) // today in format of "MM/dd/yy"
        if postDue != "" {
            let index = postDue.index(postDue.startIndex, offsetBy: 8)
            let dueInFormat = postDue[..<index] // due in format of "MM/dd/yy"
            
            if today.elementsEqual(dueInFormat) {
                return true // this post due today
            }
        }
        return false // this post is not due today
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
        if snapshot.hasChild("notifications") {
            let value = snapshot.value as? NSDictionary
            var notifications = value?.value(forKey: mode) as! [Any]
            notifications.append(completedPost.toAnyObject())
            self.UsersRef.child(member).child("notifications").updateChildValues([mode: notifications])
        } else {
            self.UsersRef.child(member).child("notifications").child(mode).setValue([completedPost.toAnyObject()])
        }
    }
    
    func setNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 192/255, green: 245/255, blue: 243/255, alpha: 1)
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
