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
        self.ToDoRef.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
          var newItems: [Category] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let category = Category(snapshot: snapshot) {
              newItems.append(category)
                print(category.name, category.key)
            }
          }
          self.categories = newItems
          self.collectionView.reloadData()
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let cell = sender as? UICollectionViewCell,
            let indexPath = self.collectionView.indexPath(for: cell) {

            // update dest controller's variable
             let vc = segue.destination as! PostListTableViewController
             //Now simply set the title property of vc
            vc.selectedCategoryKey = categories[indexPath.row].key as String
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
        print(cell.nameLabel.text as Any) // cell.nameLabel.text is changed collectly. Not displayed
        return cell
    }

    // MARK: - Button Actions

    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        // popup
        let addPopUp = UIAlertController(title: "Add Category",
                                         message: "Type name to add Todo category",
                                         preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = addPopUp.textFields?.first,
                let text = textField.text else { return }
          
            // firebase operation
            let category = Category(aName: text,
                                    anAddedByUser: "self.user.name")
            let categoryRef = self.ToDoRef.childByAutoId()
            categoryRef.setValue(category.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        addPopUp.addTextField()
        
        addPopUp.addAction(saveAction)
        addPopUp.addAction(cancelAction)
        
        present(addPopUp, animated: true, completion: nil)
        self.collectionView.reloadData()
    }
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
