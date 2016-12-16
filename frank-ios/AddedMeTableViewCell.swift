//
//  FriendRequestTableViewCell.swift
//  frank-ios
//
//  Created by Winston Tri on 12/6/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit

class AddedMeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addButton.layer.borderWidth = 0.5
        addButton.layer.cornerRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(name: String, row: Int) {
        nameLabel.text = name
        addButton.tag = row
        addButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    func setConfirm() {
        addButton.layer.borderColor = FrankColors.ArmyGreen.cgColor
        addButton.layer.backgroundColor = UIColor.white.cgColor
        addButton.setTitleColor(FrankColors.ArmyGreen, for: .normal)
        addButton.setTitle("  confirm  ", for: .normal)
    }
    
    func setFriends() {
        addButton.layer.backgroundColor = FrankColors.ArmyGreen.cgColor
        addButton.layer.borderColor = FrankColors.ArmyGreen.cgColor
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.setTitle("  friends  ", for: .normal)
    }
    
    func setPending() {
        addButton.layer.borderColor = FrankColors.Zambezi.cgColor
        addButton.layer.backgroundColor = FrankColors.Zambezi.cgColor
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.setTitle("  requested  ", for: .normal)

    }
    
    func setAdd() {
        addButton.layer.borderColor = FrankColors.NewYorkPink.cgColor
        addButton.layer.backgroundColor = UIColor.white.cgColor
        addButton.setTitleColor(FrankColors.NewYorkPink, for: .normal)
        addButton.setTitle("  add  ", for: .normal)
    }
    
}
