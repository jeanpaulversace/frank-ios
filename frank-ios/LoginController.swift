//
//  ViewController.swift
//  frank-ios
//
//  Created by Winston Tri on 9/2/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate  {
    /*!
     @abstract Sent to the delegate when the button was used to logout.
     @param loginButton The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // Do not need log out function
    }

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fbLoginButton.delegate = self
    }
    
    // FBSDKLoginButtonDelegate Methods
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil)
        {
            // Process error
            print("Error was encountered during Facebook Login: \(error)")
        }
        else if result.isCancelled {
            // Handle cancellations
            print("Facebook Login was cancelled")
        }
        else {
            fbLoginButton.isHidden = true
            // Facebook Login was successful
            // Find or create user on server
            if let accessToken = FBSDKAccessToken.current() {
                UserService.login(accessToken: accessToken).then { result -> Void in
                    
                    if let resultDictionary = result as? [String: Any],
                        let user = resultDictionary["user"] as? [String:Any] {
                        
                        // Set Current User global variable
                        do {
                            let currentUser = try User(json: user)
                            if let unwrappedCurrentUser = currentUser {
                                UserService.currentUser = unwrappedCurrentUser
                            }
                        } catch {
                            UserService.currentUser = nil
                        }
                        
                        if resultDictionary["isNew"] != nil {
                            // New User
                            // Proceed to Phone Verification screen
                            OperationQueue.main.addOperation {
                                [weak self] in
                                self?.performSegue(withIdentifier: "SignUp", sender: self)
                            }
                        } else {
                            // Existing User
                            OperationQueue.main.addOperation {
                                [weak self] in
                                self?.performSegue(withIdentifier: "Feelings", sender: self)
                            }
                        }
                        
                    }
                    
                    
                }.catch { error in
                    print("Error occurred trying to login or sign up: \(error)")
                    
                    FBSDKLoginManager.init().logOut()
                    
                    self.fbLoginButton.isHidden = false
                    
                    
                }
            }
        }
    }

}

