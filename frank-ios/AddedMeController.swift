//
//  FriendRequestsController.swift
//  frank-ios
//
//  Created by Winston Tri on 12/6/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//
//  How to keep track of state on UITableViewCell's add button?
//  View is not responsible for maintaining state
//

import UIKit
import NVActivityIndicatorView

enum FriendRequestStatus {
    case Confirm
    case Add
    case Friends
    case Pending
}

class AddedMeController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate:FeelingsController! = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    var activityIndicator : NVActivityIndicatorView!
    
    var friendRequests = [FriendRequest]()
    var friendRequestsStatus = [String:FriendRequestStatus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            activityIndicator = NVActivityIndicatorView(frame: self.view.frame, type: NVActivityIndicatorType.ballScaleRipple, color: UIColor.darkGray, padding: NVActivityIndicatorView.DEFAULT_PADDING)
            self.tableView.addSubview(self.refreshControl)
            // Hide separator lines for intial empty tableview
            tableView.separatorStyle = .none
            tableView.rowHeight = 60.0
        }
        
        let addedMeTableViewCellNib = UINib(nibName: "AddedMeTableViewCell", bundle: nil)
        tableView.register(addedMeTableViewCellNib, forCellReuseIdentifier: "AddedMe")
        
        updateTableViewWithFriendRequests(table: self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia-Italic", size: 24)!]
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        updateTableViewWithFriendRequests(table: tableView)
        DispatchQueue.main.async {
            refreshControl.endRefreshing()
        }
    }
    
    func updateTableViewWithFriendRequests(table: UITableView) {
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }

        if UserService.currentUser != nil {
            
            FriendRequestService.get().then { result -> Void in
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                self.friendRequests = [FriendRequest]()
                self.friendRequestsStatus = [String:FriendRequestStatus]()
                
                if let resultDictionary = result as? [[String:Any]] {
                    
                    if resultDictionary.count == 0 {
                        self.createEmptyStateLabel()
                        DispatchQueue.main.async {
                            self.tableView.separatorStyle = .none
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tableView.separatorStyle = .singleLine
                        }
                    }
                    
                    for object in resultDictionary {
                        let friendRequest = try FriendRequest.init(json: object)
                        if let unwrappedFriendRequest = friendRequest {
                            self.friendRequests.append(unwrappedFriendRequest)
                            self.friendRequestsStatus[unwrappedFriendRequest.fromUser.id] = FriendRequestStatus.Confirm
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            
                }.catch { error in
                    
                    print("Error occurred trying to find possible friends: \(error)")
                    
                    // Set possible friends to empty array
                    self.activityIndicator.stopAnimating()
            }
            
        }
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendRequests.count
    }
    
    func createEmptyStateLabel() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width:self.tableView.bounds.width, height: self.tableView.bounds.height))
        label.font = UIFont (name: "Georgia-Italic", size: 24)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        label.text = "No Friend Requests"
        
        DispatchQueue.main.async {
            self.tableView.addSubview(label)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : AddedMeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddedMe") as! AddedMeTableViewCell
        
        // Configure the cell...
        let friendRequest = friendRequests[indexPath.row]
        
        cell.configureCell(name: friendRequest.fromUser.name, row: indexPath.row)
        cell.selectionStyle = .none
        
        cell.addButton.addTarget(self, action: #selector(self.addButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
        
        updateAddButton(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func updateAddButton(cell: AddedMeTableViewCell, indexPath: IndexPath) {
        
        let friendRequest = friendRequests[indexPath.row]
        let fromUser = friendRequest.fromUser
        let status = friendRequestsStatus[fromUser.id]
        
        switch status! {
        case FriendRequestStatus.Confirm:
            cell.setConfirm()
        case FriendRequestStatus.Add:
            cell.setAdd()
        case FriendRequestStatus.Friends:
            cell.setFriends()
        case FriendRequestStatus.Pending:
            cell.setPending()
        }
    }
    
    func addButtonPressed(sender: UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let optIndexPath = self.tableView.indexPathForRow(at: buttonPosition)
        if let indexPath = optIndexPath, let cell = tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {

            let friendRequest = friendRequests[indexPath.row]
            let status = friendRequestsStatus[friendRequest.fromUser.id]
            
            switch status! {
            case FriendRequestStatus.Confirm:
                // Go to server, add friend to each user's friends, delete friend request
                self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Friends
                confirmFriendRequest(friendRequest: friendRequest, indexPath: indexPath)
            case FriendRequestStatus.Add:
                // Go to server, create friend request
                self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Pending
                createFriendRequest(friendRequest: friendRequest, indexPath: indexPath)
            case FriendRequestStatus.Friends:
                // Go to server, remove friend from each user's friends
                let alert = UIAlertController(title: "Unfriend this user?", message: "You will have to send another request to be friends", preferredStyle: UIAlertControllerStyle.actionSheet)
                let unfriend = UIAlertAction(title: "Unfriend", style: UIAlertActionStyle.destructive, handler: { (alert) in
                    self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Add
                    self.removeFriends(friendRequest: friendRequest, indexPath: indexPath)
                })
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(unfriend)
                alert.addAction(cancel)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            case FriendRequestStatus.Pending:
                // Go to server, delete friend request
                self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Add
                deleteFriendRequest(friendRequest: friendRequest, indexPath: indexPath)
            }
            
            self.updateAddButton(cell: cell, indexPath: indexPath)
        }
        
        
    }
    
    func confirmFriendRequest(friendRequest: FriendRequest, indexPath: IndexPath) {
        
        if let currentUser = UserService.currentUser {
            
            let friend = friendRequest.fromUser
            
            FriendService.addFriends(user: currentUser, friend: friend).then { result in
                
                return FriendRequestService.delete(friendRequest: friendRequest)
                
                }.then { result -> Void in
                
                    // Adding Friends and Deleting Friend Request was successful
                    self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Friends
                    DispatchQueue.main.async {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                            self.updateAddButton(cell: cell, indexPath: indexPath)
                        }
                    }
                
                }.catch { error in
                    print("Error occurred during the server's confirmation of FriendRequest (delete Friend Request and add both User's to each others' Friends property: \(error)")
                    
                    self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Confirm
                    DispatchQueue.main.async {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                            self.updateAddButton(cell: cell, indexPath: indexPath)
                        }
                    }
                    
            }
        }
    }
    
    func createFriendRequest(friendRequest: FriendRequest, indexPath: IndexPath) {
        
        if let currentUser = UserService.currentUser {
            let friend = friendRequest.fromUser
            do {
                let newFriendRequest = try FriendRequest.init(id: "", fromUser: currentUser, toUser: friend, createdAt: FrankDateFormatter.formatter.string(from: Date()), updatedAt: FrankDateFormatter.formatter.string(from: Date()))
                
                FriendRequestService.create(friendRequests: [newFriendRequest]).then { result -> Void in
                    // Creating Friend Request was successful
                    
                    if let resultDictionary = result as? [[String:Any]], let createdFriendRequest = try FriendRequest(json: resultDictionary.first!), let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                        
                        self.friendRequests[indexPath.row] = createdFriendRequest
                        self.friendRequestsStatus[createdFriendRequest.fromUser.id] = FriendRequestStatus.Pending
                        DispatchQueue.main.async {
                            self.updateAddButton(cell: cell, indexPath: indexPath)
                        }
                    }
                    }.catch { error in
                        print("Error occurred during server creation of FriendRequest: \(error)")
                        
                        self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Add
                        DispatchQueue.main.async {
                            if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                                self.updateAddButton(cell: cell, indexPath: indexPath)
                            }
                        }
                        
                }
                
            } catch {
               print("Error creating new Friend Request on the client-side")
            }
        }
    }
    
    func removeFriends(friendRequest: FriendRequest, indexPath: IndexPath) {
        
        if let currentUser = UserService.currentUser {
            let friend = friendRequest.fromUser
            
            FriendService.removeFriends(user: currentUser, friend: friend).then { result -> Void in
                
                // Removing Friends was successful
                self.friendRequestsStatus[friend.id] = FriendRequestStatus.Add
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                        self.updateAddButton(cell: cell, indexPath: indexPath)
                    }                }
                
                }.catch { error in
                    print("Error occurred during server removal of both Users from each other's friends: \(error)")
                    
                    self.friendRequestsStatus[friend.id] = FriendRequestStatus.Friends
                    DispatchQueue.main.async {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                            self.updateAddButton(cell: cell, indexPath: indexPath)
                        }
                    }
                    
            }
        }
    }
    
    
    func deleteFriendRequest(friendRequest: FriendRequest, indexPath: IndexPath) {

        FriendRequestService.delete(friendRequest: friendRequest).then { result -> Void in
            // Removing Friends and Deleting Friend Request was successful
            self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Add
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                    self.updateAddButton(cell: cell, indexPath: indexPath)
                }
            }
            
            }.catch { error in
                print("Error occurred during server deletion of FriendRequest: \(error)")
                
                self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Pending
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                        self.updateAddButton(cell: cell, indexPath: indexPath)
                    }
                }
                
        }
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

    // MARK: - Navigation
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        delegate.popBackToFeelings()
    }

    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
