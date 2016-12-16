//
//  FeelingsController.swift
//  frank-ios
//
//  Created by Winston Tri on 11/16/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit
import MessageUI
import Koloda

class FeelingsController: UIViewController, SettingsControllerDelegate, SettingsBackToFeelingsDelegate, CreateFeelingDelegate, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate {
    
    var feelings = [Feeling]()
    var hasUserBoughtIn : Bool = false
    
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var noFeelingsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        
        self.noFeelingsLabel.isHidden = true
        
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        checkForUserBuyIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForUserBuyIn() {
        FeelingService.getCreatedByCurrentUserInPastDay().then { result -> Void in
            if let resultDictionary = result as? [[String:Any]] {
                if resultDictionary.count > 0 {
                    self.hasUserBoughtIn = true
                    self.loadFeelings()
                } else {
                    self.performSegue(withIdentifier: "Create", sender: self)
                }
            }
            
            }.catch { error in
                print("Error checking if user has bought in: \(error)")
        }
    }
    
    func loadFeelings() {
        
        FeelingService.get().then { result -> Void in
            
            if let resultDictionary = result as? [[String:Any]] {
                
                self.feelings = [Feeling]()
                var uniqueUsers = [String]()
                
                for object in resultDictionary {
                    let feeling = try Feeling.init(json: object)
                    if let unwrappedFeeling = feeling {
                        if !uniqueUsers.contains(unwrappedFeeling.creator.id) {
                            uniqueUsers.append(unwrappedFeeling.creator.id)
                            self.feelings.append(unwrappedFeeling)
                        }
                    }
                }
                
                self.feelings = self.feelings.sorted(by: { $0.createdAt > $1.createdAt })
            }
            
            self.kolodaView.reloadData()
            
            }.catch { error in
                print("Error retrieving User's Feelings feed from the server: \(error)")
        }
    }
    
    // MARK - Button Pressed Methods
    
    func textButtonPressed(sender: UIButton) {
        let feeling = feelings[kolodaView.currentCardIndex]
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "What's up? How was your day?";
        messageVC.recipients = [feeling.creator.phoneNumber]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue:
            print("message cancelled")
            
        case MessageComposeResult.failed.rawValue:
            print("message failed")
            
        case MessageComposeResult.sent.rawValue:
            print("message sent")
            
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func callButtonPressed(sender: UIButton) {
        let feeling = feelings[kolodaView.currentCardIndex]
        if let url = NSURL(string: "tel://\(feeling.creator.phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }

    
    // MARK - Button Methods
    
    @IBAction func frankLogoButtonPressed(_ sender: UIButton) {
        // Move to SettingsController
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: "Settings", sender: self)
        }
    }

    @IBAction func plusButtonpressed(_ sender: Any) {
        //
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: "Create", sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Create" {
            let viewController = segue.destination as! CreateFeelingController
            viewController.delegate = self
            viewController.hasUserBoughtIn = self.hasUserBoughtIn
        } else if segue.identifier == "Settings" {
            let viewController = segue.destination as! SettingsController
            viewController.delegate = self
        } else if segue.identifier == "AddedMe" {
            let viewController = segue.destination as! AddedMeController
            viewController.delegate = self
        } else if segue.identifier == "AddFriends" {
            let viewController = segue.destination as! AddContactsController
            viewController.delegate = self
        }else if segue.identifier == "MyFriends" {
            let viewController = segue.destination as! MyFriendsController
            viewController.delegate = self
        }
    }
    
    // MARK: - Create Feelings Delegate
    func feelingWasCreated(success: Bool) {
        self.dismiss(animated: true, completion: {
            if success {
                self.loadFeelings()
            }
        })
    }
    
    func exitedCreateFeeling() {
        self.dismiss(animated: true, completion: {
            self.loadFeelings()
        })
    }
    
    // MARK: - Settings Delegate
    func popBackToFeelings() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func settingsControllerDismissed(segue: SettingsControllerSegues) {
        
        self.dismiss(animated: true, completion: {
            
            switch segue {
            case SettingsControllerSegues.Profile:
                self.performSegue(withIdentifier: "Profile", sender: self)
            case SettingsControllerSegues.AddedMe:
                self.performSegue(withIdentifier: "AddedMe", sender: self)
            case SettingsControllerSegues.AddFriends:
                self.performSegue(withIdentifier: "AddFriends", sender: self)
            case SettingsControllerSegues.MyFriends:
                self.performSegue(withIdentifier: "MyFriends", sender: self)
            case SettingsControllerSegues.None:
                break
            }
            
        })
        
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: KolodaViewDelegate
extension FeelingsController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
    
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        
    }
}

//MARK: KolodaViewDataSource
extension FeelingsController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return self.feelings.count
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> FeelingCardView {
        let feelingCard = FeelingCardView(frame: self.kolodaView.frame)
        let feeling = self.feelings[Int(index)]
        let profilePictureUrl = NSURL(string: "http://graph.facebook.com/\(feeling.creator.facebookId)/picture?type=large")
        
        feelingCard.configureFeelingCard(name: feeling.creator.name, rating: feeling.rating, profilePictureUrl: profilePictureUrl as! URL)
        
        feelingCard.textButton.addTarget(self, action: #selector(self.textButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
        feelingCard.callButton.addTarget(self, action: #selector(self.callButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
}
