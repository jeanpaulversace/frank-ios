//
//  AddFriendsController.swift
//  frank-ios
//
//  Created by Winston Tri on 11/28/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit
import Contacts
import PromiseKit
import Alamofire
import NVActivityIndicatorView

class AddContactsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    var activityIndicator : NVActivityIndicatorView!
    
    var users = [User]()
    var selectedUsers = [User]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        activityIndicator = NVActivityIndicatorView(frame: self.view.frame, type: NVActivityIndicatorType.ballScaleRipple, color: UIColor.darkGray, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        
        // Hide separator lines for intial empty tableview
        tableView.separatorStyle = .none
        tableView.rowHeight = 60.0
        
        // Load custom tableview cell and register
        let addContactsTableViewCellNib = UINib(nibName: "AddContactsTableViewCell", bundle: nil)
        tableView.register(addContactsTableViewCellNib, forCellReuseIdentifier: "AddContacts")
        
        updateTableViewWithPossibleFriends(tableView: self.tableView)
        
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        do {
            try createFriendRequests()
        } catch{
            print("Failed to create friend requests!")
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        segueToFeelingsView()
    }
    
    func createFriendRequests() throws {
        
        // Create Array of Friend Request Dictionaries
        var friendRequestArray = [FriendRequest]()
        
        if let currentUser = UserService.currentUser {
            
            for selectedUser in selectedUsers {
                
                let fromToId = currentUser.id + selectedUser.id
                
                let friendRequest = try FriendRequest(id: "", fromUser: currentUser, toUser: selectedUser, fromToId: fromToId, createdAt: FrankDateFormatter.formatter.string(from: Date()), updatedAt: FrankDateFormatter.formatter.string(from: Date()))
                friendRequestArray.append(friendRequest)
                
            }
            
            FriendRequestService.create(friendRequests: friendRequestArray).then { result -> Void in
                
                if result is [String:Any] {
                    // FriendRequest creation was successful, go to Feelings View
                    self.segueToFeelingsView()
                }
            }
            
        }
    }
    
    func updateTableViewWithPossibleFriends (tableView: UITableView) {
        
        self.activityIndicator.startAnimating()
        
        let contacts = getContacts()
        
        getPossibleFriends(contacts: contacts).then { result -> Void in
            
            // Start activity indicator
            self.activityIndicator.stopAnimating()
            self.users = [User]()
            
            if let resultDictionary = result as? [[String:Any]] {
                for object in resultDictionary {
                    let user = try User.init(json: object)
                    if let unwrappedUser = user {
                        self.users.append(unwrappedUser)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.separatorStyle = .singleLine
                    self.tableView.reloadData()
                }
            }
            
            }.catch { error in
                
                print("Error occurred trying to find possible friends: \(error)")
                
                // Set possible friends to empty array
                self.activityIndicator.stopAnimating()
        }

        
    }
    
    func updateSendButton() {
        if (selectedUsers.count == 0) {
            sendButton.isHidden = true
        } else {
            sendButton.isHidden = false
        }
    }
    
    func getContacts() -> [CNContact] {
        
        let contactStore = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var contacts: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                contacts.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return contacts
    }
    
    func getPossibleFriends(contacts: [CNContact]) -> Promise<Any> {
        
        var phoneNumberArray : [String] = []
        
        for contact in contacts {
            for label in contact.phoneNumbers {
                let numberStringArray = label.value.stringValue.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
                let formattedNumber = numberStringArray.joined(separator: "")
                
                if (formattedNumber.characters.count == 10) {
                    phoneNumberArray.append(formattedNumber)
                }
                
            }
        }
        
        let accessToken = FBSDKAccessToken.current().tokenString!
        
        let accessTokenUrlSnippet = "?access_token=\(accessToken)"
        
        let url = Constants.serverUrl + "/api/add-friends/" + accessTokenUrlSnippet
        
        return Promise { fulfill, reject in
            Alamofire.request(url, method: .post, parameters : ["phoneNumbers":phoneNumberArray], encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let dict):
                        fulfill(dict)
                    case .failure(let error):
                        reject(error)
                    }
            }
        }

    }
    
    // MARK: - NAVIGATION
    func segueToFeelingsView() {
        // Move to the Feelings View
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: "Feelings", sender: self)
        }
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddContactsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddContacts") as! AddContactsTableViewCell
        
        // Configure the cell...
        let user = users[indexPath.row]
        
        cell.configureCell(name: user.name)
        cell.selectionStyle = .none
        
        updateAddButtonForRow(indexPath: indexPath)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = users[indexPath.row]
        
        // Exit method if selectedUsers contains selectedUser
        if selectedUsers.contains(where: { $0 === selectedUser}) {
            return
        }
        
        selectedUsers.append(selectedUser)
        
        updateAddButtonForRow(indexPath: indexPath)
        updateSendButton()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let deselectedUser = users[indexPath.row]
        
        if let userIndex = selectedUsers.index(where: {$0 === deselectedUser}) {
            selectedUsers.remove(at: userIndex)
        }
        
        updateAddButtonForRow(indexPath: indexPath)
        updateSendButton()
    }
    
    func updateAddButtonForRow(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AddContactsTableViewCell {

            if selectedUsers.contains(where: { $0 === users[indexPath.row]}) {
                cell.setDeselected()
            } else {
                cell.setDeselected()
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
