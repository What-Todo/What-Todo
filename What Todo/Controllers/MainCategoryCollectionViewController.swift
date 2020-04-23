//
//  MainCategoryCollectionViewController.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class MainCategoryCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    let ref = Database.database().reference(withPath: "ToDoLists")
    var categories: [Category] = []
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let addPopUp = UIAlertController(title: "Add Category",
                                         message: "Type name to add Todo category",
                                         preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = addPopUp.textFields?.first,
                let text = textField.text else { return }
          
            // init(aDetails: String, completed: Bool, anAddedByUser: String, createdAt: String, updatedAt: String, key: String = "")
            let category = Category(aName: text, anAddedByUser: "self.user.name")
            let categoryRef = self.ref.child(text.lowercased())
            categoryRef.setValue(category.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        addPopUp.addTextField()
        
        addPopUp.addAction(saveAction)
        addPopUp.addAction(cancelAction)
        
        present(addPopUp, animated: true, completion: nil)
        
        
        
//        let addPopUp = UIAlertController(title: "Add Category",
//                                         message: "Type to add Todo Category",
//                                         preferredStyle: .alert)
//
//        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
//            // init(aName: String, completed: Bool, anAddedByUser: String, key: String = "")
//            let category = Category(aName: addPopUp.textFields![0].text ?? "Error: nil in addPopUp.textFields![0].text", anAddedByUser: self.user.name)
//
//            self.categories.append(category)
//            self.collectionView.reloadData()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel",
//                                         style: .cancel)
//
//        addPopUp.addTextField()
//
//        addPopUp.addAction(saveAction)
//        addPopUp.addAction(cancelAction)
//
//        present(addPopUp, animated: true, completion: nil)
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
