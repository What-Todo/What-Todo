//
//  ProfileViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/30/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var recentActivitiesTableView: UITableView!
    
    @IBOutlet weak var completedCounterLabel: UILabel!
    @IBOutlet weak var madeCounterLabel: UILabel!
    
    
    var recentActivities: [Post] = []
    
    let LoginVC = "LoginVC"
    let UsersRef = Database.database().reference(withPath: "Users")
    let currentUser = Auth.auth().currentUser
    let StorageRef = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        recentActivitiesTableView.backgroundView = UIImageView(image: UIImage(named: "pink"))
        recentActivitiesTableView.backgroundColor = UIColor.clear
        self.showUserProfile()
        // Do any additional setup after loading the view.
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
            } else {
                self.completedCounterLabel?.text = String(0)
            }
            let madeCounter = value?.value(forKey: "madeCounter") as? NSNumber
            if let madeCounterInt = madeCounter?.intValue {
                self.madeCounterLabel?.text = String(madeCounterInt)
            } else {
                self.madeCounterLabel?.text = String(0)
            }
            
        })
        
        UsersRef.child(currentUser!.uid).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let completedCounter = value?.value(forKey: "completedCounter") as? NSNumber
            if let compCounterInt = completedCounter?.intValue {
                self.completedCounterLabel?.text = String(compCounterInt)
            } else {
                self.completedCounterLabel?.text = String(0)
            }
            let madeCounter = value?.value(forKey: "madeCounter") as? NSNumber
            if let madeCounterInt = madeCounter?.intValue {
                self.madeCounterLabel?.text = String(madeCounterInt)
            } else {
                self.madeCounterLabel?.text = String(0)
            }
        }
        
        UsersRef.child(currentUser!.uid).child("recentActivities").observe(.childAdded) { (snapshot) in
            if let post = Post(snapshot: snapshot) {
                self.recentActivities.insert(post, at: 0)
            }
            self.recentActivitiesTableView.reloadData()
        }
        
        // get image
        StorageRef.child(currentUser!.uid).downloadURL { (url, error) in
            let userProfilePhotoRef = self.StorageRef.child(self.currentUser!.uid)
            userProfilePhotoRef.getData(maxSize: 1024 * 1024) { (data, error) in
                if let error = error { return } else {
                    let image = UIImage(data: data!)
                    self.profileImageView.image = image
                }
            }
        }
        
//        UsersRef.child(currentUser!.uid).child("recentActivities").observeSingleEvent(of: .value) { (snapshot) in
//            for child in snapshot.children {
//                if let snapshot = child as? DataSnapshot,
//                    let post = Post(snapshot: snapshot) {
//                    self.recentActivities.append(post)
//                }
//            }
//            self.recentActivitiesTableView.reloadData()
//        }
        
    }

    @IBAction func profileImageViewDidTouch(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        profileImageView.image = image
        uploadImage(image, info)
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage, _ info: [UIImagePickerController.InfoKey : Any]) {
        // Upload the file to the path "images/rivers.jpg"
        let userProfilePhotoRef = StorageRef.child(currentUser!.uid)
//        let photoPath = info[UIImagePickerController.InfoKey.referenceURL] as! NSURL
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        let imageData = image.jpegData(compressionQuality: 0.8)
        userProfilePhotoRef.putData(imageData!, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
            }
        }
        
//        let uploadTask = userProfilePhotoRef.putFile(from: photoPath as URL, metadata: nil) { (metadata, error) in
//          guard let _ = metadata else {return}
//        }
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentActivitiesTableViewCell", for: indexPath) as! RecentActivitiesTableViewCell
        cell.userNameLabel?.text = " "
        cell.detailsLabel?.text = " "
        cell.dueLabel?.text = " "
        
//        if recentActivities.count > 0 {
//            // detailsLabel
//            
//            let thisPost = recentActivities[indexPath.row]
//            cell.detailsLabel?.text = thisPost.details
//            
//            // dispalyName
//            UsersRef.child(thisPost.addedByUser).observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                cell.userNameLabel!.text = value?["displayName"] as? String ?? "failed"
//            })
//            
//            // due
//            cell.dueLabel!.text = thisPost.due
//        }

        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont.init(name: "Noteworthy", size: 20)
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
