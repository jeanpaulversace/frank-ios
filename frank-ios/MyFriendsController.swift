//
//  MyFriendsController.swift
//  frank-ios
//
//  Created by Winston Tri on 12/7/16.
//  Copyright © 2016 jeanpaulversace. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MyFriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate:FeelingsController! = nil
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator : NVActivityIndicatorView!
    
    var friends = [User]()
    var friendRequests = [Int:FriendRequest]()
    
    var friendRequestsStatus = [String:FriendRequestStatus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = NVActivityIndicatorView(frame: self.view.frame, type: NVActivityIndicatorType.ballScaleRipple, color: UIColor.darkGray, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        
        // Hide separator lines for intial empty tableview
        tableView.separatorStyle = .none
        tableView.rowHeight = 60.0
        
        let addedMeTableViewCellNib = UINib(nibName: "AddedMeTableViewCell", bundle: nil)
        tableView.register(addedMeTableViewCellNib, forCellReuseIdentifier: "AddedMe")
        
        updateTableViewWithFriends(table: self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia-Italic", size: 24)!]
    }
    
    func updateTableViewWithFriends(table: UITableView) {
        
        self.activityIndicator.startAnimating()
        
        if let currentUser = UserService.currentUser {
            
            FriendService.get(user: currentUser).then { result -> Void in
                self.activityIndicator.stopAnimating()
                
                self.friends = [User]()
                self.friendRequests = [Int:FriendRequest]()

                self.friendRequestsStatus = [String:FriendRequestStatus]()
                
                if let resultDictionary = result as? [[String:Any]] {
                    
                    if resultDictionary.count == 0 {
                        self.createEmptyStateLabel()
                        self.tableView.separatorStyle = .none
                    } else {
                        self.tableView.separatorStyle = .singleLine
                    }
                    
                    for object in resultDictionary {
                        let friend = try User.init(json: object)
                        if let unwrappedFriend = friend {
                            self.friends.append(unwrappedFriend)
                            self.friendRequestsStatus[unwrappedFriend.id] = FriendRequestStatus.Friends
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
        
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }
    
    func createEmptyStateLabel() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width:self.tableView.bounds.width, height: self.tableView.bounds.height))
        label.font = UIFont (name: "Georgia-Italic", size: 24)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        label.text = "No Friends"
        
        self.tableView.addSubview(label)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddedMeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddedMe") as! AddedMeTableViewCell
        
        // Configure the cell...
        let friend = friends[indexPath.row]
        
        cell.configureCell(name: friend.name, row: indexPath.row)
        cell.selectionStyle = .none
        
        cell.addButton.addTarget(self, action: #selector(self.addButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
        
        updateAddButton(cell: cell,indexPath: indexPath)
        
        return cell
    }
    
    func updateAddButton(cell: AddedMeTableViewCell, indexPath: IndexPath) {
        
        let friend = friends[indexPath.row]
        let status = friendRequestsStatus[friend.id]
        
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
        if let indexPath = optIndexPath, let cell = tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell{
            
            let friend = friends[indexPath.row]
            let status = friendRequestsStatus[friend.id]
            
            switch status! {
            case FriendRequestStatus.Confirm:
                // Go to server, add friend to each user's friends, delete friend request
                if let friendRequest = friendRequests[indexPath.row] {
                    self.friendRequestsStatus[friend.id] = FriendRequestStatus.Friends
                    confirmFriendRequest(friendRequest: friendRequest, indexPath: indexPath)
                }
            case FriendRequestStatus.Add:
                // Go to server, create friend request
                self.friendRequestsStatus[friend.id] = FriendRequestStatus.Pending
                createFriendRequest(friend: friend, indexPath: indexPath)
            case FriendRequestStatus.Friends:
                // Go to server, remove friend from each user's friends
                self.friendRequestsStatus[friend.id] = FriendRequestStatus.Add
                removeFriends(friend: friend, indexPath: indexPath)
            case FriendRequestStatus.Pending:
                // Go to server, delete friend request
                if let friendRequest = friendRequests[indexPath.row] {
                    self.friendRequestsStatus[friend.id] = FriendRequestStatus.Add
                    deleteFriendRequest(friendRequest: friendRequest, indexPath: indexPath)
                }
            }
            
            self.updateAddButton(cell: cell,indexPath: indexPath)
        }
        
        
    }
    
    func confirmFriendRequest(friendRequest: FriendRequest, indexPath: IndexPath) {
        
        if let currentUser = UserService.currentUser {
            
            let friend = friendRequest.toUser
            
            FriendService.addFriends(user: currentUser, friend: friend).then { result in
                
                return FriendRequestService.delete(friendRequest: friendRequest)
                
                }.then { result -> Void in
                    
                    // Adding Friends and Deleting Friend Request was successful
                    self.friendRequestsStatus[friend.id] = FriendRequestStatus.Friends
                    DispatchQueue.main.async {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                            self.updateAddButton(cell: cell, indexPath: indexPath)
                        }
                    }
                    
                }.catch { error in
                    print("Error occurred during the server's confirmation of FriendRequest (delete Friend Request and add both User's to each others' Friends property: \(error)")
                    
                    self.friendRequestsStatus[friend.id] = FriendRequestStatus.Confirm
                    DispatchQueue.main.async {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                            self.updateAddButton(cell: cell, indexPath: indexPath)
                        }
                    }
                    
            }
        }
    }
    
    func createFriendRequest(friend: User, indexPath: IndexPath) {
        
        if let currentUser = UserService.currentUser {
            
            do {
                let newFriendRequest = try FriendRequest.init(id: "", fromUser: currentUser, toUser: friend, createdAt: FrankDateFormatter.formatter.string(from: Date()), updatedAt: FrankDateFormatter.formatter.string(from: Date()))
                
                FriendRequestService.create(friendRequests: [newFriendRequest]).then { result -> Void in
                    // Creating Friend Request was successful
                    
                    if let resultDictionary = result as? [[String:Any]], let createdFriendRequest = try FriendRequest(json: resultDictionary.first!), let cell = self.tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
                        
                        self.friendRequests[indexPath.row] = createdFriendRequest
                        self.friendRequestsStatus[friend.id] = FriendRequestStatus.Pending
                        DispatchQueue.main.async {
                            self.updateAddButton(cell: cell, indexPath: indexPath)
                        }
                    }
                    }.catch { error in
                        print("Error occurred during server creation of FriendRequest: \(error)")
                        
                        self.friendRequestsStatus[friend.id] = FriendRequestStatus.Add
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
    
    func removeFriends(friend: User, indexPath: IndexPath) {
        
        if let currentUser = UserService.currentUser {
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
