//
//  TermsAndServicesController.swift
//  frank-ios
//
//  Created by Winston Tri on 11/30/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit
import Contacts

class TermsAndServicesController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.continueButton.layer.borderColor = UIColor.darkGray.cgColor
        self.continueButton.layer.borderWidth = 0.5
        self.continueButton.layer.cornerRadius = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func continueButtonPressed(_ sender: UIButton) {
        
        self.requestContactsAccess { (isAccessGranted) in
            if isAccessGranted {
                OperationQueue.main.addOperation {
                    [weak self] in
                    self?.performSegue(withIdentifier: "AddContacts", sender: self)
                }
            }
        }
        
    }
    
    func requestContactsAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            store.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Contacts Access Denied", message: "Please go to Settings > Frank and allow Contacts access", preferredStyle: UIAlertControllerStyle.alert)
                            let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
                            alert.addAction(action)
                            self.show(alert, sender: nil)
                        }
                    }
                }
            })
            
        default:
            completionHandler(false)
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
