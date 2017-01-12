//
//  MyProfileController.swift
//  frank-ios
//
//  Created by Winston Tri on 12/19/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit

class MyProfileController: UIViewController, UITextFieldDelegate {
    
    var delegate:FeelingsController! = nil

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.phoneNumberTextField.frame.size.height - width, width:  self.phoneNumberTextField.frame.size.width, height: self.phoneNumberTextField.frame.size.height)
        border.borderWidth = width
        self.phoneNumberTextField.layer.addSublayer(border)
        self.phoneNumberTextField.layer.masksToBounds = true
        self.phoneNumberTextField.tintColor = UIColor.darkGray
        
        self.saveButton.layer.borderColor = UIColor.darkGray.cgColor
        self.saveButton.layer.borderWidth = 0.5
        self.saveButton.layer.cornerRadius = 2
        
        if let currentUser = UserService.currentUser {
            self.phoneNumberTextField.text = currentUser.phoneNumber
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia-Italic", size: 24)!]
        
        if let currentUser = UserService.currentUser {
            let fullName = currentUser.name
            let fullNameArr = fullName.components(separatedBy: " ")
            let firstName: String = fullNameArr.first!
            self.title = "\(firstName)'s Profile"
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.delegate.popBackToFeelings()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let phoneNumber = self.phoneNumberTextField.text {
            if (self.isPhoneNumberValid(phoneNumber)) {
                let stringArray = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
                let formattedPhoneNumber = stringArray.joined(separator: "")
                do {
                    try self.updateUserPhoneNumber(phoneNumber: formattedPhoneNumber)
                } catch {
                    print("Failed to update user's phone number!")
                }
            } else {
                let alert = UIAlertController(title: "Invalid Phone Number", message: "Please enter a valid 10-digit number", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func isPhoneNumberValid( _ phoneNumber: String) -> Bool {
        let stringArray = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        
        if (newString.characters.count == 10) {
            return true
        }
        
        return false
    }
    
    func updateUserPhoneNumber (phoneNumber: String) throws {
        
        guard let currentUser = UserService.currentUser else {
            throw SessionError.NoCurrentUser
        }
        
        let userToBeUpdated = try User(id: currentUser.id, facebookId: currentUser.facebookId, accessToken: currentUser.accessToken, email: currentUser.email, name: currentUser.name, phoneNumber: phoneNumber, createdAt: FrankDateFormatter.formatter.string(from: currentUser.createdAt), updatedAt: FrankDateFormatter.formatter.string(from: Date()), friends: currentUser.friends)
        
        UserService.update(user: userToBeUpdated).then { result -> Void in
            
            if let resultDictionary = result as? [[String: Any]] {
                
                // Set Current User global variable
                do {
                    let currentUser = try User(json: resultDictionary.first!)
                    if let unwrappedCurrentUser = currentUser {
                        UserService.currentUser = unwrappedCurrentUser
                        OperationQueue.main.addOperation {
                            [weak self] in
                            self?.delegate.popBackToFeelings()
                        }
                    }
                } catch {
                    UserService.currentUser = nil
                }
                
            }
            
            }.catch { error in
                print("Error occurred trying to update user: \(error)")
        }
        
    }
    
    // UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.phoneNumberTextField {
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
            
        } else {
            return true
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
