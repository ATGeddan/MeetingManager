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

class UsersTableVC: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var myUser = User()
    var users = [User]()
    var myTeam = Team()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        self.title = "MEMBERS"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! cell1
        cell.cellName.text = users[indexPath.row].userFirstName + " " + users[indexPath.row].userLastName
        let url = URL(string: users[indexPath.row].imageURL)
        cell.cellImage.kf.setImage(with: url)
        cell.cellImage.layer.cornerRadius = cell.cellImage.frame.size.width / 2
        cell.cellPosition.text = users[indexPath.row].position
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        performSegue(withIdentifier: "showProfile", sender: selectedUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? PublicProfileVC {
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
        Database.database().reference().child("Teams").child(myUser.teamID).child("Members").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = User(data: dictionary)
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }

}

