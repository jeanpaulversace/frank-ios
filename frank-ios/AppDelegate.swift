//
//  AppDelegate.swift
//  frank-ios
//
//  Created by Winston Tri on 9/2/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    @nonobjc func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let window = self.window {
            
            if let accessToken = FBSDKAccessToken.current() {
                UserService.login(accessToken: accessToken).then { result -> Void in
                    
                    if let resultDictionary = result as? [String: Any],
                        let user = resultDictionary["user"] as? [String:Any] {
                        
                        // Set Current User global variable
                        do {
                            let currentUser = try User(json: user)
                            if let unwrappedCurrentUser = currentUser {
                                UserService.currentUser = unwrappedCurrentUser
                                
                                // Present Feelings
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let rootController = storyboard.instantiateViewController(withIdentifier: "FeelingsNavigation") as! UINavigationController
                                window.rootViewController = rootController
                                window.makeKeyAndVisible()
                                self.doLoadingAnimation(window: window)
                            }
                        } catch {
                            UserService.currentUser = nil
                        }
                        
                    }
                    
                    
                    }.catch { error in
                        print("Error occurred trying to login or sign up: \(error)")
                        
                        FBSDKLoginManager.init().logOut()
                        
                        // Present Login
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let rootController = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginController
                        window.rootViewController = rootController
                        
                }
            }
            
        }
        
        
        return true
    }
    
    func doLoadingAnimation(window: UIView) {
        if let pinkCircle = UIImage(named: "pink"), let blueCircle = UIImage(named: "blue"),
            let greenCircle = UIImage(named: "green"), let purpleCircle = UIImage(named: "purple") {
            
            let pinkImageView = UIImageView(frame: CGRect(x: window.frame.origin.x-60, y: window.center.y, width: 30, height: 30))
            pinkImageView.image  = pinkCircle
            
            let blueImageView = UIImageView(frame: CGRect(x: window.frame.origin.x-60, y: window.center.y, width: 30, height: 30))
            blueImageView.image  = blueCircle
            
            let greenImageView = UIImageView(frame: CGRect(x: window.frame.origin.x-60, y: window.center.y, width: 30, height: 30))
            greenImageView.image  = greenCircle
            
            let purpleImageView = UIImageView(frame: CGRect(x: window.frame.origin.x-60, y: window.center.y, width: 30, height: 30))
            purpleImageView.image  = purpleCircle
            
            let whiteBG = UIView(frame: window.frame)
            whiteBG.backgroundColor = UIColor.white
            
            window.addSubview(whiteBG)
            window.addSubview(pinkImageView)
            window.addSubview(blueImageView)
            window.addSubview(greenImageView)
            window.addSubview(purpleImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                pinkImageView.frame.origin.x = window.center.x + 75
            }, completion: { (result) in
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    blueImageView.frame.origin.x = window.center.x + 15
                }, completion: { (result) in
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        greenImageView.frame.origin.x = window.center.x - 45
                    }, completion: { (result) in
                        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                            purpleImageView.frame.origin.x = window.center.x - 105
                        }, completion: { (result) in
                            UIView.transition(with: window, duration: 1.0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                                whiteBG.removeFromSuperview()
                                pinkImageView.removeFromSuperview()
                                blueImageView.removeFromSuperview()
                                greenImageView.removeFromSuperview()
                                purpleImageView.removeFromSuperview()
                            }, completion: nil)
                        })
                    })
                })
            })
            
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    @nonobjc func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }

}

