//
//  InvitationKeyTableViewCell.swift
//  What Todo
//
//  Created by Soma Yoshida on 5/4/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import UIKit
import Firebase

class InvitationKeyTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var categoryKeyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
