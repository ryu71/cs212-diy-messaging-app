//
//  CustomMessageCell.swift
//  DIY Text Messaging
//
//  Created by Raymond Yu on 4/10/19.
//  Copyright © 2019 CS212. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var messageBackground: UIView!
    @IBOutlet var messageBody: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageBackground.layer.cornerRadius = 17
    }
}
