//
//  SettingsController.swift
//  frank-ios
//
//  Created by Winston Tri on 12/6/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit

enum SettingsControllerSegues {
    case AddedMe
    case AddFriends
    case MyFriends
    case MyProfile
    case None
}

protocol SettingsControllerDelegate {
    func settingsControllerDismissed(segue: SettingsControllerSegues)
}

protocol SettingsBackToFeelingsDelegate {
    func popBackToFeelings()
}

class SettingsController: UIViewController {
    
    var delegate:SettingsControllerDelegate! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        self.delegate.settingsControllerDismissed(segue: SettingsControllerSegues.MyProfile)
    }
    
    @IBAction func addedMeButtonPressed(_ sender: Any) {
        self.delegate.settingsControllerDismissed(segue: SettingsControllerSegues.AddedMe)
    }
    
    @IBAction func addFriendsButtonPressed(_ sender: Any) {
        self.delegate.settingsControllerDismissed(segue: SettingsControllerSegues.AddFriends)
    }
    
    @IBAction func myFriendsButtonPressed(_ sender: Any) {
        self.delegate.settingsControllerDismissed(segue: SettingsControllerSegues.MyFriends)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.delegate.settingsControllerDismissed(segue: SettingsControllerSegues.None)
    }

    @IBAction func swipedDown(_ sender: Any) {
        self.delegate.settingsControllerDismissed(segue: SettingsControllerSegues.None)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
