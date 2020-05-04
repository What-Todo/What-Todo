//
//  NotificationTableViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 5/1/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class NotificationTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")
    let UsersRef = Database.database().reference(withPath: "Users")
    let currentUser = Auth.auth().currentUser
    let segmentedControlData = ["Cooperative", "Competitive"]
    var notifications: [Post] = []
    var mode: String = "Cooperative"
    
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationTableView.delegate = self
        self.notificationTableView.dataSource = self

        segmentedControl.setTitle(segmentedControlData[0], forSegmentAt: 0)
        segmentedControl.setTitle(segmentedControlData[1], forSegmentAt: 1)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        getNotifications()
    }

    // MARK: - Notification Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell

        // detailsLabel
        let thisPost = notifications[indexPath.row]
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
    
    
    
    func getNotifications() {
        UsersRef.child(currentUser!.uid).child("notifications").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.mode) {
                self.UsersRef.child(self.currentUser!.uid).child("notifications").child(self.mode).observeSingleEvent(of: .value) { (snapshot) in
                    for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot,
                            let post = Post(snapshot: snapshot) {
                            self.notifications.append(post)
                        }
                    }
                    self.notificationTableView.reloadData()
                }
            }
        })
    }

    @IBAction func modeSegmentControlDidTouch(_ sender: Any) {
        notifications = []
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mode = segmentedControlData[0]
        case 1:
            mode = segmentedControlData[1]
        default:
            break
        }
        getNotifications()
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
