//
//  PhoneVerificationController.swift
//  frank-ios
//
//  Created by Winston Tri on 11/15/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit

class PhoneVerificationController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
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
        
        self.confirmButton.layer.borderColor = UIColor.darkGray.cgColor
        self.confirmButton.layer.borderWidth = 0.5
        self.confirmButton.layer.cornerRadius = 2
        
        self.phoneNumberTextField.becomeFirstResponder()
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        if let phoneNumber = self.phoneNumberTextField.text {
            if (self.isPhoneNumberValid(phoneNumber)) {
                // Continue to next screen
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

}
