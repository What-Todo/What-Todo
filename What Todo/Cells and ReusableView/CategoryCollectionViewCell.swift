//
//  CategoryCollectionViewCell.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/23/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class CategoryCollectionViewCell: UICollectionViewCell {
    // MARK: UI Propaties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var modeLabel: UILabel!
    var cellColor: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 
}
