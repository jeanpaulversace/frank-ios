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
    
    func configureFeelingCard(name: String, rating: Int, profilePictureUrl: URL) {
        DispatchQueue.main.async {
            self.nameLabel.text = name
            self.profilePictureImageView.downloadedFrom(url: profilePictureUrl)
            
            profilePictureImageView.layer.borderWidth = 1
            profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.width/2
            profilePictureImageView.layer.borderColor = UIColor.darkText.cgColor
            profilePictureImageView.clipsToBounds = true
            
            self.layer.cornerRadius = 4
            
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

}
