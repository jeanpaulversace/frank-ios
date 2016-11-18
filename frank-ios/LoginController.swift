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
        // Log out
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
            self.loginServer(accessToken: FBSDKAccessToken.current())
        }
    }
    
    // Get User from server
    func loginServer(accessToken:FBSDKAccessToken) {
        var fbAuthRequest = URLRequest(url: URL(string: "http://10.24.104.171:8080/auth/facebook/token?access_token=\(accessToken.tokenString!)")!)
        fbAuthRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: fbAuthRequest) { data, response, error in
            guard let data = data, error == nil else {
                // Fundamental Network Error
                print("Error occurred trying to connect: \(error)")
                
                // Log user out of Facebook
                FBSDKLoginManager.init().logOut()
                self.fbLoginButton.isHidden = false
                
                // self.showErrorAlertWith(message: "Network Error")
                
                return
            }
            
            // Server error
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Server encountered error with HTTP Status: \(httpStatus.statusCode)")
                
                // Log user out of Facebook
                FBSDKLoginManager.init().logOut()
                self.fbLoginButton.isHidden = false
                
                // self.showErrorAlertWith(message: "Unexpected Error")
            }
            
            self.fbLoginButton.isHidden = true
            
            // Request returned successfully
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String: Any] {
                
                if dictionary["isNew"] != nil {
                    // New User
                    // Proceed to Phone Verification screen
                    OperationQueue.main.addOperation {
                        [weak self] in
                        self?.performSegue(withIdentifier: "SignUp", sender: self)
                    }                } else {
                    // Existing User
                    OperationQueue.main.addOperation {
                        [weak self] in
                        self?.performSegue(withIdentifier: "Feelings", sender: self)
                    }                }
                
            }
            
        }
        task.resume()
    }

}

