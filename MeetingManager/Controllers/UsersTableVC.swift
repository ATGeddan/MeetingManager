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

class UsersTableVC: UIViewController, UITableViewDelegate , UITableViewDataSource, changeAdminDelegate, didRemoveDelegate {
    
    @IBOutlet weak var tableView: UITableView!
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
        tableView.addSubview(refreshControl)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! cell1
        let user = users[indexPath.row]
        cell.cellName.text = user.userFirstName + " " + user.userLastName
        let url = URL(string: user.imageURL)
        cell.cellImage.kf.setImage(with: url)
        cell.cellImage.layer.cornerRadius = cell.cellImage.frame.size.width / 2
        cell.cellPosition.text = user.position
        if user.userID == myTeam.adminID {
            cell.adminBadge.isHidden = false
        } else {
            cell.adminBadge.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        performSegue(withIdentifier: "showProfile", sender: selectedUser)
    }
    
    func didChangeAdmin(id:String) {
        myTeam.updateAdmin(id: id)
        tableView.reloadData()
    }
    
    func didRemoveMember() {
        users = []
        getUsers()
        tableView.reloadData()
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
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? PublicProfileVC {
            destination.delegate = self
            destination.delegate2 = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            if let user = sender as? User {
                destination.selectedUser = user
            }
            destination.myUser = myUser
            destination.myTeam = myTeam
        }
    }
    
    func getUsers() {
        Database.database().reference().child("Teams").child(myUser.teamID).child("Members").observeSingleEvent(of: .value) { (snapshot) in
            self.users = []
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for child in children {
                    if let dictionary = child.value as? [String:AnyObject] {
                        let user = User(data: dictionary)
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func updateUsers() {
        let teamid = myUser.teamID
        Database.database().reference().child("Teams").child(teamid!).child("Members").observe(.childAdded) { (snapshot) in
            self.users = []
            self.getUsers()
            self.tableView.reloadData()
        }
        Database.database().reference().child("Teams").child(teamid!).child("Members").observe(.childRemoved) { (snapshot) in
            self.users = []
            self.getUsers()
            self.tableView.reloadData()
        }
    }

}

