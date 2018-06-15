//
//  UsersTableVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class UsersTableVC: UIViewController, UITableViewDelegate , UITableViewDataSource, changeAdminDelegate, didRemoveMemberDelegate {
  
  @IBOutlet weak var membersTableView: UITableView!
  
  var myUser = User()
  var users = [User]()
  var myTeam = Team()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if myUser.userID == myTeam.adminID {
      updateUsers()
    } else {
      getUsers()
    }
    
    self.title = "MEMBERS"
    membersTableView.addSubview(refreshControl)
  }
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "membersCell", for: indexPath) as! membersCell
    let user = users[indexPath.row]
    cell.updateUI(user:user,team:myTeam)
    return cell
  }
  
  internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 57.0
  }
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedUser = users[indexPath.row]
    performSegue(withIdentifier: "showProfile", sender: selectedUser)
  }
  
  internal func didChangeAdmin(id:String) {
    myTeam.updateAdmin(id: id)
    membersTableView.reloadData()
  }
  
  internal func didRemoveMember() {
    users = []
    getUsers()
    membersTableView.reloadData()
  }
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action:
      #selector(self.handleRefresh),
                             for: UIControlEvents.valueChanged)
    refreshControl.tintColor = UIColor.white
    
    return refreshControl
  }()
  
  @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    users = []
    getUsers()
    membersTableView.reloadData()
    refreshControl.endRefreshing()
  }
  
  
  
  fileprivate func getUsers() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("Members").observeSingleEvent(of: .value) { (snapshot) in
      self.users = []
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        for child in children {
          if let dictionary = child.value as? [String:AnyObject] {
            let user = User(data: dictionary)
            self.users.append(user)
            self.membersTableView.reloadData()
          }
        }
      }
    }
  }
  
  fileprivate func updateUsers() {
    guard let teamid = myUser.teamID else {return}
    Database.database().reference().child("Teams").child(teamid).child("Members").observe(.childAdded) { (snapshot) in
      self.users = []
      self.getUsers()
      self.membersTableView.reloadData()
    }
    Database.database().reference().child("Teams").child(teamid).child("Members").observe(.childRemoved) { (snapshot) in
      self.users = []
      self.getUsers()
      self.membersTableView.reloadData()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let destination = segue.destination as? PublicProfileVC, let user = sender as? User {
      destination.delegate = self
      destination.delegate2 = self
      let backItem = UIBarButtonItem()
      backItem.title = ""
      navigationItem.backBarButtonItem = backItem
      destination.selectedUser = user
      destination.myUser = myUser
      destination.myTeam = myTeam
    }
  }
  
}

