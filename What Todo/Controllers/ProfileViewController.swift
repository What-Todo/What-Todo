//
//  ProfileViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/30/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var recentActivitiesTableView: UITableView!
    
    @IBOutlet weak var completedCounterLabel: UILabel!
    @IBOutlet weak var madeCounterLabel: UILabel!
    
    
    var recentActivities: [Post] = []
    
    let LoginVC = "LoginVC"
    let UsersRef = Database.database().reference(withPath: "Users")
    let currentUser = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showUserProfile()
        // Do any additional setup after loading the view.
        self.recentActivitiesTableView.reloadData()
    }
    
    func showUserProfile() {

        UsersRef.child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            self.nameLabel?.text = value?.value(forKey: "displayName") as? String
            self.locationLabel?.text = value?.value(forKey: "location") as? String
            
            let completedCounter = value?.value(forKey: "completedCounter") as? NSNumber
            if let compCounterInt = completedCounter?.intValue {
                self.completedCounterLabel?.text = String(compCounterInt)
            }
            let madeCounter = value?.value(forKey: "madeCounter") as? NSNumber
            if let madeCounterInt = madeCounter?.intValue {
                self.madeCounterLabel?.text = String(madeCounterInt)
            }
            
        })
        
        UsersRef.child(currentUser!.uid).child("recentActivities").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let post = Post(snapshot: snapshot) {
                    self.recentActivities.append(post)
                }
            }
            self.recentActivitiesTableView.reloadData()
        }
        
    }

    
    @IBAction func logOutDidTouch(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let main = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = main.instantiateViewController(withIdentifier: LoginVC)
            view.window?.rootViewController = loginViewController
            view.window?.makeKeyAndVisible()
        } catch {
            print("Sign out Failed")
        }
    }
    
    
    // MARK: Recent Activities Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentActivitiesTableViewCell", for: indexPath) as! RecentActivitiesTableViewCell
        if recentActivities.count != 0 {
            // detailsLabel
            let thisPost = recentActivities[indexPath.row]
            cell.detailsLabel?.text = thisPost.details
            
            // dispalyName
            UsersRef.child(thisPost.addedByUser).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                cell.userNameLabel!.text = value?["displayName"] as? String ?? "failed"
            })
            
            // due
            cell.dueLabel!.text = thisPost.due
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
       return "Recent Activities"
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
