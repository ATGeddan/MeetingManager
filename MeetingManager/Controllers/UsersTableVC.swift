//
//  UsersTableVC.swift
//  MeetingManager
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class UsersTableVC: UIViewController, UITableViewDelegate , UITableViewDataSource, adminActions {
  
  @IBOutlet weak var membersTableView: UITableView!
  @IBOutlet weak var requestNumber: UILabel!
  @IBOutlet weak var requestBG: UIImageView!
  
  var myUser = User()
  var users = [User]()
  var notApprovedUsers = [User]()
  var myTeam = Team()
  var showRequests = true
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if myUser.userID == myTeam.adminID {
      updateUsers()
      if myTeam.joinStatus == "private" {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Requests     ", style: .plain, target: self, action: #selector(toggleRequests))
        requestNumber.isHidden = false
        requestBG.isHidden = false
      }
    } else {
      getUsers()
    }
    
    self.title = "MEMBERS"
    membersTableView.addSubview(refreshControl)
  }
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = 0
    if showRequests {
      count = users.count
    } else {
      count = notApprovedUsers.count
    }
    return count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "membersCell", for: indexPath) as! membersCell
    if showRequests {
      let user = users[indexPath.row]
      cell.configMemberCell(user:user,team:myTeam)
      cell.hideBTNs()
    } else {
      let user = notApprovedUsers[indexPath.row]
      cell.configMemberCell(user:user,team:myTeam)
      cell.showBTNs(indexPath.row)
    }
    return cell
  }
  
  internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 57.0
  }
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if showRequests {
      let selectedUser = users[indexPath.row]
      performSegue(withIdentifier: "showProfile", sender: selectedUser)
    } else {
      let selectedUser = notApprovedUsers[indexPath.row]
      performSegue(withIdentifier: "showProfile", sender: selectedUser)
    }
  }
  
  @IBAction func handleConfirms(_ sender: UIButton) {
    let theUser = notApprovedUsers[sender.tag]
    Database.database().reference().child("Teams").child(myTeam.id).child("Members").child(theUser.userID).updateChildValues(["joinStatus":"default"])
    Database.database().reference().child("Users").child(theUser.userID).updateChildValues(["joinStatus":"default"])
    Database.database().reference().child("Teams").child(myTeam.id).child("NewRequests").child(theUser.userID).removeValue()
  }
  
  @IBAction func handleDeclines(_ sender: UIButton) {
    let theUser = notApprovedUsers[sender.tag]
    Database.database().reference().child("Teams").child(myTeam.id).child("Members").child(theUser.userID).removeValue()
    Database.database().reference().child("Users").child(theUser.userID).updateChildValues(["joinStatus":"default","team":""])
  }
  
  func didChangeAdmin(id:String) {
    myTeam.updateAdmin(id: id)
    navigationItem.rightBarButtonItem = nil
    requestNumber.isHidden = true
    requestBG.isHidden = true
    membersTableView.reloadData()
  }
  
  func didRemoveMember() {
    users = []
    getUsers()
    membersTableView.reloadData()
  }
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self,
                            action:#selector(self.handleRefresh),
                            for: UIControl.Event.valueChanged)
    refreshControl.tintColor = UIColor.white
    
    return refreshControl
  }()
  
  @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    users = []
    getUsers()
    membersTableView.reloadData()
    refreshControl.endRefreshing()
  }
  
  @objc fileprivate func toggleRequests() {
    showRequests = !showRequests
    Database.database().reference().child("Teams").child(myTeam.id).child("NewRequests").removeValue()
    membersTableView.reloadData()
  }
  
  fileprivate func getUsers() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("Members").observeSingleEvent(of: .value) { (snapshot) in
      self.users = []
      self.notApprovedUsers = []
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        for child in children {
          if let dictionary = child.value as? [String:AnyObject] {
            let user = User(dictionary)
            if user.joinStatus == "private" {
              self.notApprovedUsers.append(user)
              self.requestNumber.text = "\(self.notApprovedUsers.count)"
            } else {
              self.users.append(user)
            }
            self.membersTableView.reloadData()
          }
        }
      }
    }
  }
  

  fileprivate func updateUsers() {
    guard let teamid = myUser.teamID else {return}
    Database.database().reference().child("Teams").child(teamid).child("Members").observe(.value) { _ in
      self.users = []
      self.notApprovedUsers = []
      self.requestNumber.text = "0"
      self.getUsers()
      self.membersTableView.reloadData()
    }
    Database.database().reference().child("Teams").child(teamid).child("Members").observe(.childRemoved) { _ in
      self.users = []
      self.notApprovedUsers = []
      self.requestNumber.text = "0"
      self.getUsers()
      self.membersTableView.reloadData()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let destination = segue.destination as? PublicProfileVC, let user = sender as? User {
      destination.delegate = self
      let backItem = UIBarButtonItem()
      backItem.title = ""
      navigationItem.backBarButtonItem = backItem
      destination.selectedUser = user
      destination.myUser = myUser
      destination.myTeam = myTeam
    }
  }
  
}

