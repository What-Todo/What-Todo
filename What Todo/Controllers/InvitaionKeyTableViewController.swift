//
//  InvitaionKeyTableViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 5/4/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class InvitaionKeyTableViewController: UITableViewController {

    var categories: [Category] = []
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")

    @IBOutlet var invitationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        getCategories()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationKeyTableViewCell", for: indexPath) as! InvitationKeyTableViewCell

        // detailsLabel
        let thisCat = categories[indexPath.row]
        cell.categoryNameLabel?.text = thisCat.name
        cell.modeLabel?.text = thisCat.mode
        cell.categoryKeyLabel?.text = thisCat.key

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let selected = categories[indexPath.row]
        let pasteboard = UIPasteboard.general
        pasteboard.string = selected.key
    }
    
    func getCategories() {
        self.ToDoRef.observe(.value, with: { snapshot in
          var newItems: [Category] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let category = Category(snapshot: snapshot) {
                if self.isMemberof(category) {
                    newItems.append(category)
                }
            }
          }
          self.categories = newItems
          self.tableView.reloadData()
        })
    }
    
    func isMemberof(_ category: Category) -> Bool {
        let catMembers = category.members
        let currentUser = Auth.auth().currentUser

        for member in catMembers {
            if currentUser!.uid.elementsEqual(member) {
                return true
            }
        }
        return false
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
