//
//  FeelingCardView.swift
//  frank-ios
//
//  Created by Winston Tri on 12/15/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit

class FeelingCardView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    
    func configureFeelingCard(name: String, rating: Int, profilePictureUrl: URL) {
        self.nameLabel.text = name
        self.profilePictureImageView.downloadedFrom(url: profilePictureUrl)
        
        switch rating {
        case 1:
            self.backgroundColor = FrankColors.Zambezi
        case 2:
            self.backgroundColor = FrankColors.ArmyGreen
        case 3:
            self.backgroundColor = FrankColors.BaliHai
        case 4:
            self.backgroundColor = FrankColors.NewYorkPink
        default:
            self.backgroundColor = UIColor.lightGray
        }
    }

}
