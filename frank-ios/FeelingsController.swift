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
    @IBOutlet weak var reloadFeelingsButton: UIButton!
    
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        
        
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        initializeViews()
        
        checkForUserBuyIn()
    }
    
    func initializeViews() {
        
        reloadFeelingsButton.layer.borderColor = UIColor.darkGray.cgColor
        reloadFeelingsButton.layer.borderWidth = 0.5
        reloadFeelingsButton.layer.cornerRadius = 6
        
        textButton.layer.borderColor = UIColor.darkGray.cgColor
        textButton.layer.borderWidth = 1.0
        textButton.layer.cornerRadius = textButton.bounds.width/2
        
        callButton.layer.borderColor = UIColor.darkGray.cgColor
        callButton.layer.borderWidth = 1.0
        callButton.layer.cornerRadius = callButton.bounds.width/2
    }
    
    func changeViewsForFeelings(empty: Bool) {
        
        if empty {
            noFeelingsLabel.isHidden = false
            reloadFeelingsButton.isHidden = true
            textButton.isHidden = true
            callButton.isHidden = true
        } else {
            noFeelingsLabel.isHidden = true
            reloadFeelingsButton.isHidden = true
            textButton.isHidden = false
            callButton.isHidden = false
        }
        
    }
    
    func changeViewsForEndOfFeelings() {
        textButton.isHidden = true
        callButton.isHidden = true
        reloadFeelingsButton.isHidden = false
        noFeelingsLabel.isHidden = true
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
                
                if (resultDictionary.count == 0) {
                    self.changeViewsForFeelings(empty: true)
                } else {
                    self.changeViewsForFeelings(empty: false)
                }
                
                self.feelings = [Feeling]()
                
                var uniqueUsers = [String]()
                var tempFeelings = [Feeling]()
                
                for object in resultDictionary {
                    let feeling = try Feeling.init(json: object)
                    if let unwrappedFeeling = feeling {
                        tempFeelings.append(unwrappedFeeling)
                    }
                }
                
                tempFeelings = tempFeelings.sorted(by: { $0.createdAt > $1.createdAt })
                
                for feeling in tempFeelings {
                    if !uniqueUsers.contains(feeling.creator.id) {
                        uniqueUsers.append(feeling.creator.id)
                        self.feelings.append(feeling)
                    }
                }
            }
            
            
            DispatchQueue.main.async {
                self.kolodaView.resetCurrentCardIndex()
            }
            
            }.catch { error in
                print("Error retrieving User's Feelings feed from the server: \(error)")
        }
    }
    
    // MARK - Button Pressed Methods
    
    @IBAction func textButtonPressed(_ sender: Any) {
        let feeling = feelings[kolodaView.currentCardIndex]
        
        let messageVC = MFMessageComposeViewController()
        
        switch feeling.rating {
        case 1:
            messageVC.body = "Did you have a bad day? What happened?"
        case 2:
            messageVC.body = "Whatcha thinking about?"
        case 3:
            messageVC.body = "Hey! Wanna hang out soon?"
        case 4:
            messageVC.body = "Tell me about your day!"
        default:
            messageVC.body = "What's up? How was your day?";
        }
        
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
    
    
    @IBAction func callButtonPressed(_ sender: Any) {
        let feeling = feelings[kolodaView.currentCardIndex]
        let name = feeling.creator.name
        let phoneNumber = feeling.creator.phoneNumber
        
        let alert = UIAlertController(title: "Call \(name)?", message: "\(phoneNumber) will be dialed", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.default, handler: { action in
            if let url = NSURL(string: "tel://\(feeling.creator.phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func reloadFeelingsButtonPressed(_ sender: UIButton) {
        loadFeelings()
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
        } else if segue.identifier == "MyFriends" {
            let viewController = segue.destination as! MyFriendsController
            viewController.delegate = self
        } else if segue.identifier == "MyProfile" {
            let viewController = segue.destination as! MyProfileController
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
            case SettingsControllerSegues.MyProfile:
                self.performSegue(withIdentifier: "MyProfile", sender: self)
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

// MARK - KolodaViewDelegate
extension FeelingsController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        changeViewsForEndOfFeelings()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        // Do nothing
    }
}

extension FeelingsController: KolodaViewDataSource {
    
    public func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if let feelingCard = Bundle.main.loadNibNamed("FeelingCardView", owner: self, options: nil)?[0] as? FeelingCardView {
            
            let feeling = self.feelings[Int(index)]
            let profilePictureUrl = NSURL(string: "https://graph.facebook.com/\(feeling.creator.facebookId)/picture?type=large&return_ssl_resources=1")
            
            feelingCard.frame = kolodaView.frame
            feelingCard.configureFeelingCard(name: feeling.creator.name, rating: feeling.rating, profilePictureUrl: profilePictureUrl as! URL)
            
            return feelingCard
            
        } else {
            return UIView(frame: kolodaView.frame)
        }
    }

    
    public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return self.feelings.count
    }

    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return Bundle.main.loadNibNamed("FeelingOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}
