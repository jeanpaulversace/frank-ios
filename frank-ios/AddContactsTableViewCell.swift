//
//  AddContactsTableViewCell.swift
//  frank-ios
//
//  Created by Winston Tri on 11/30/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit

class AddContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(name: String) {
        nameLabel.text = name
    }
    
    func setSelected() {
        if let checked = UIImage(named: "checked") {
            addButton.setImage(checked, for: .normal)
        }
    }
    
    func setDeselected() {
        if let unchecked = UIImage(named: "unchecked") {
            addButton.setImage(unchecked, for: .normal)
        }
    }
    
    
}
