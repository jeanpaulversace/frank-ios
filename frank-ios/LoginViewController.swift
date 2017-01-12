//
//  ViewController.swift
//  frank-ios
//
//  Created by Winston Tri on 9/2/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.current() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            // Get user information from serveer
            self.loginServer(accessToken:FBSDKAccessToken.current())
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        
    }

    
    // FBSDKLoginButtonDelegate Methods
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // User logged out
    }
    
    // Get User from server
    func loginServer(accessToken:FBSDKAccessToken) {
        let url = NSURL(string: "http://localhost:8080/auth/facebook/token?access_token=<\(accessToken)>")
        
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            print("User is logged in")
        }
        
        task.resume()
    }

}

