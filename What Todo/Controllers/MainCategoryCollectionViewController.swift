//
//  MainCategoryCollectionViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class MainCategoryCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    var categories: [Category] = []
    var user: User!
    var imageNum = 0
    let ToDoRef = Database.database().reference(withPath: "ToDoLists")
    
    @IBOutlet var catCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
        
        // Synchronizing Data to the Collection view
        getCategories()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let cell = sender as? UICollectionViewCell,
            let indexPath = self.collectionView.indexPath(for: cell) {

            // update dest controller's variable
             let PostLTVC = segue.destination as! PostListTableViewController
            PostLTVC.selectedCategoryKey = categories[indexPath.row].key as String
            PostLTVC.cellColor = indexPath.row % 3
         }
        if let TodayTableVC = segue.destination as? TodayTableViewController {
            // pass selectedCategoryKey to
            TodayTableVC.categories = self.categories
        }
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
    
        print(indexPath)
        // Configure the cell
        let thisCat = categories[indexPath.row]
        cell.nameLabel?.text = thisCat.name
        cell.modeLabel?.text = thisCat.mode
        colorSet(cell)
        return cell
    }
    
    // header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategoryCollectionReusableView", for: indexPath)
            // Customize headerView here
            return headerView
        }
        fatalError()
    }
    
    func getCategories() {
        self.ToDoRef.observe(.value, with: { snapshot in
          var newItems: [Category] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let category = Category(snapshot: snapshot) {
                print(category.name, category.key + "\n")
                if self.isMemberof(category) {
                    newItems.append(category)
                }
            }
          }
          self.categories = newItems
          self.collectionView.reloadData()
        })
    }
    
    func isMemberof(_ category: Category) -> Bool {
        let catMembers = category.members
        let currentUser = Auth.auth().currentUser

        for member in catMembers {
            print(currentUser!.uid, member)
            if currentUser!.uid.elementsEqual(member) {
                return true
            }
        }
        return false
    }
    
    func colorSet(_ cell: CategoryCollectionViewCell) {
        var image: UIImage = UIImage(named: "yellow")!
        switch imageNum {
        case 0:
            image = UIImage(named: "yellow")!
            cell.cellColor = 0
            imageNum = 1
            break
        case 1:
            image = UIImage(named: "pink")!
            cell.cellColor = 1
            imageNum = 2
            break
        case 2:
            image = UIImage(named: "blue")!
            cell.cellColor = 2
            imageNum = 0
        default:
            break
        }
        cell.imageView.image = image
    }

    // MARK: - Button Actions
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension MainCategoryCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.size.width/2.0 - 8,
                      height: collectionView.frame.size.width/2.0 - 8)
    }
}


