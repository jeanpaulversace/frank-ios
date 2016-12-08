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
    
    func updateTableViewWithFriends(table: UITableView) {
        
        self.activityIndicator.startAnimating()
        
        if let currentUser = UserService.currentUser {
            
            FriendService.get(user: currentUser).then { result -> Void in
                self.activityIndicator.stopAnimating()
                
                self.friends = [User]()
                self.friendRequestsStatus = [String:FriendRequestStatus]()
                
                if let resultDictionary = result as? [[String:Any]] {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddedMeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddedMe") as! AddedMeTableViewCell
        
        // Configure the cell...
        let friend = friends[indexPath.row]
        
        cell.configureCell(name: friend.name, row: indexPath.row)
        cell.selectionStyle = .none
        
        cell.addButton.addTarget(self, action: #selector(self.addButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
        
        updateAddButton(indexPath: indexPath)
        
        return cell
    }
    
    func updateAddButton(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AddedMeTableViewCell {
            
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
    }
    
    func addButtonPressed(sender: UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let optIndexPath = self.tableView.indexPathForRow(at: buttonPosition)
        if let indexPath = optIndexPath {
            
            let friend = friends[indexPath.row]
            let status = friendRequestsStatus[friend.id]
            
            switch status! {
            case FriendRequestStatus.Confirm:
                // Go to server, add friend to each user's friends, delete friend request
                if let friendRequest = friendRequests[indexPath.row] {
                    self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Friends
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
            
            self.updateAddButton(indexPath: indexPath)
        }
        
        
    }
    
    func confirmFriendRequest(friendRequest: FriendRequest, indexPath: IndexPath) {
        let friend = friendRequest.fromUser
        
        if let currentUser = UserService.currentUser {
            FriendService.addFriends(user: currentUser, friend: friend).then { result in
                return FriendRequestService.delete(friendRequest: friendRequest)
                }.then { result -> Void in
                    
                    // Adding Friends and Deleting Friend Request was successful
                    self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Friends
                    DispatchQueue.main.async {
                        self.updateAddButton(indexPath: indexPath)
                    }
                    
            }
        }
    }
    
    func createFriendRequest(friend: User, indexPath: IndexPath) {
        
        if let currentUser = UserService.currentUser {
            do {
                let newFriendRequest = try FriendRequest.init(id: "", fromUser: currentUser, toUser: friend, fromToId: currentUser.id+friend.id, createdAt: FrankDateFormatter.formatter.string(from: Date()), updatedAt: FrankDateFormatter.formatter.string(from: Date()))
                
                FriendRequestService.create(friendRequests: [newFriendRequest]).then { result -> Void in
                    // Creating Friend Request was successful
                    
                    if let resultDictionary = result as? [[String:Any]] {
                        for object in resultDictionary {
                            let friendRequest = try FriendRequest.init(json: object)
                            if let unwrappedFriendRequest = friendRequest {
                                self.friendRequests[indexPath.row] = unwrappedFriendRequest
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.separatorStyle = .singleLine
                            self.tableView.reloadData()
                        }
                    }

                    
                    self.friendRequestsStatus[friend.id] = FriendRequestStatus.Pending
                    DispatchQueue.main.async {
                        self.updateAddButton(indexPath: indexPath)
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
                
                // Removing Friends and Deleting Friend Request was successful
                self.friendRequestsStatus[friend.id] = FriendRequestStatus.Add
                DispatchQueue.main.async {
                    self.updateAddButton(indexPath: indexPath)
                }
                
            }
        }
    }
    
    
    func deleteFriendRequest(friendRequest: FriendRequest, indexPath: IndexPath) {
        
        FriendRequestService.delete(friendRequest: friendRequest).then { result -> Void in
            // Removing Friends and Deleting Friend Request was successful
            self.friendRequests[indexPath.row] = nil
            self.friendRequestsStatus[friendRequest.fromUser.id] = FriendRequestStatus.Add
            DispatchQueue.main.async {
                self.updateAddButton(indexPath: indexPath)
            }
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
