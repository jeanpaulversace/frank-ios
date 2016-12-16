//
//  CreateFeelingController.swift
//  frank-ios
//
//  Created by Winston Tri on 12/13/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit

protocol CreateFeelingDelegate {
    func feelingWasCreated(success: Bool)
    func exitedCreateFeeling()
}

class CreateFeelingController: UIViewController {
    
    var hasUserBoughtIn : Bool = true
    var delegate:FeelingsController! = nil

    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buttonOne.layer.borderColor = UIColor.clear.cgColor
        buttonOne.layer.borderWidth = 0.5
        buttonOne.layer.cornerRadius = buttonOne.bounds.width/2
        buttonOne.clipsToBounds = true
        
        buttonTwo.layer.borderColor = UIColor.clear.cgColor
        buttonTwo.layer.borderWidth = 0.5
        buttonTwo.layer.cornerRadius = buttonTwo.bounds.width/2
        buttonTwo.clipsToBounds = true
        
        buttonThree.layer.borderColor = UIColor.clear.cgColor
        buttonThree.layer.borderWidth = 0.5
        buttonThree.layer.cornerRadius = buttonThree.bounds.width/2
        buttonThree.clipsToBounds = true
        
        buttonFour.layer.borderColor = UIColor.clear.cgColor
        buttonFour.layer.borderWidth = 0.5
        buttonFour.layer.cornerRadius = buttonFour.bounds.width/2
        buttonFour.clipsToBounds = true
        
        // User forced to create feeling
        if !hasUserBoughtIn {
            explanationLabel.text = "In order to see how your friends are feeling, you must \"buy in\" by telling them how you're feeling. Let's keep it real."
            backButton.isEnabled = false
            backButton.isHidden = true
        }
    }
    
    @IBAction func buttonOnePressed(_ sender: UIButton) {
        createFeeling(rating: 1)
    }
    
    @IBAction func buttonTwoPressed(_ sender: UIButton) {
        createFeeling(rating: 2)
    }
    
    @IBAction func buttonThreePressed(_ sender: UIButton) {
        createFeeling(rating: 3)
    }
    
    @IBAction func buttonFourPressed(_ sender: UIButton) {
        createFeeling(rating: 4)
    }
    
    func createFeeling(rating: Int) {
        if let currentUser = UserService.currentUser {
            do {
                let feeling = try Feeling(id: "", rating: rating, creator: currentUser, createdAt: FrankDateFormatter.formatter.string(from: Date()), updatedAt: FrankDateFormatter.formatter.string(from: Date()))
                
                FeelingService.create(feeling: feeling).then {
                    result -> Void in
                    
                    if let resultDictionary = result as? [[String:Any]] {
                        if resultDictionary.count > 0 {
                           self.delegate.feelingWasCreated(success: true)
                        } else {
                            self.delegate.feelingWasCreated(success: false)
                        }
                    }
                    }.catch { error in
                        print("Error occurred during server creation of Feeling: \(error)")
                        self.delegate.feelingWasCreated(success: false)
                }
            } catch {
                print("Error creating the feeling on the client-side")
                
                let alert = UIAlertController(title: "Error Creating Feeling", message: "Please try selecting your feeling again", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegate.exitedCreateFeeling()
    }

    @IBAction func swipedDown(_ sender: UISwipeGestureRecognizer) {
        if hasUserBoughtIn {
            delegate.exitedCreateFeeling()
        }
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
