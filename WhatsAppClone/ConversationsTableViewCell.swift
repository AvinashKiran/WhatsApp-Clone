//
//  ConversationsTableViewCell.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: CustomizableImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
