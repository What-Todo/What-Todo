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
    
    @IBOutlet weak var recentActivitiesTableViewCell: UITableView!
    
    let LoginVC = "LoginVC"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showUserProfile()

        // Do any additional setup after loading the view.
    }
    
    func showUserProfile() {
        let currentUser = Auth.auth().currentUser
        let UsersRef = Database.database().reference(withPath: "Users")

        UsersRef.child(currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            self.nameLabel?.text = value?.value(forKey: "displayName") as? String
            self.locationLabel?.text = value?.value(forKey: "location") as? String
            print(self.nameLabel.text! + " and " + self.locationLabel.text!)
            
          }) { (error) in
            print(error.localizedDescription)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentActivitiesTableViewCell", for: indexPath) as! PostTableViewCell

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
