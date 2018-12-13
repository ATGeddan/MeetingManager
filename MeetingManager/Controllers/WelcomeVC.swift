//
//  WelcomeVC.swift
//  MeetingManager
//
//  Created by Ahmed Eltabbal on 5/27/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase

class WelcomeVC: UIViewController {
  
  @IBOutlet weak var createBtn: UIButton!
  @IBOutlet weak var joinBtn: UIButton!
  @IBOutlet weak var teamNameLabel: UILabel!
  @IBOutlet weak var requestView: UIView!
  @IBOutlet weak var teamPass: UITextField!
  @IBOutlet weak var teamName: UITextField!
  @IBOutlet weak var helloLabel: UILabel!
  var myUser = User()
  var myID: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getMyUserInfo()
  }
  
  @IBAction func signOut() {
    do {
      try Auth.auth().signOut()
      Database.database().reference().child("Users").child(myID).removeAllObservers()
      performSegue(withIdentifier: "signedOut", sender: nil)
      
    } catch {
      print(error.localizedDescription)
    }
    
  }
  
  @IBAction func createPressed(_ sender: Any) {
    performSegue(withIdentifier: "CreateTeam", sender: myUser)
  }
  
  @IBAction func joinPressed(_ sender: Any) {
    view.endEditing(true)
    let myUserRef = Database.database().reference().child("Users").child(self.myUser.userID)
    Database.database().reference().child("teamRef").observeSingleEvent(of: .value) { (snap) in
      if let children = snap.children.allObjects as? [DataSnapshot] {
        if children.count > 0 {
          for child in children {
            if let dict = child.value as? [String:AnyObject] {
              let team = Team(dict)
              if team.name.lowercased() == self.teamName.text! || team.name == self.teamName.text! || team.name.capitalized == self.teamName.text! {
                if team.pass == self.teamPass.text! { // Correct info given
                  myUserRef.updateChildValues(["team":team.id,"joinStatus":team.joinStatus])
                  let newMember = ["email" :self.myUser.userEmail,
                                   "firstname" : self.myUser.userFirstName,
                                   "lastname" : self.myUser.userLastName,
                                   "city" : self.myUser.userCity,
                                   "profilepicURL" : self.myUser.imageURL,
                                   "uid" : self.myUser.userID,
                                   "position":self.myUser.position,
                                   "birth":self.myUser.birth,
                                   "country":self.myUser.birth,
                                   "phone":self.myUser.phone,
                                   "joinStatus":team.joinStatus,
                                   "team":team.id]
                  Database.database().reference().child("Teams").child(team.id).child("Members").child(self.myUser.userID).setValue(newMember)
                  if team.joinStatus == "private" {
                    Database.database().reference().child("Teams").child(team.id).child("NewRequests").child(self.myUser.userID).setValue(["1":"1"])
                  }
                  self.myUser.teamID = team.id
                  self.myUser.updateJoinStatus(status: team.joinStatus)
                } else { // Wrong Pass
                  self.displayBasicAlert(title: "Incorrect", msg: "Team password is incorrect")
                }
              } else {
                self.displayBasicAlert(title: "Incorrect", msg: "Team name is incorrect")
              }
            }
          }
        }
      }
    }
  }
  
  @IBAction func cancelPressed(_ sender: Any) {
    guard let teamID = myUser.teamID else {return}
    Database.database().reference().child("Teams").child(teamID).child("NewRequests").child(self.myUser.userID).removeValue()
    Database.database().reference().child("Teams").child(teamID).child("Members").child(myUser.userID).removeValue()
    Database.database().reference().child("Users").child(myUser.userID).updateChildValues(["team":"","joinStatus":"default"])
    myUser.teamID = ""
    myUser.updateJoinStatus(status: "default")
    teamPass.text = ""
    monitorMyTeamStatus()
  }
  
  private func getMyUserInfo() {
    myID = Auth.auth().currentUser?.uid ?? ""
    Database.database().reference().child("Users").child(myID).removeAllObservers()
    Database.database().reference().child("Users").child(myID).observe(.value, with: { (snapshot) in
      if let dictionary = snapshot.value as? [String:AnyObject] {
        self.myUser.updateUser(dictionary)
        self.helloLabel.text = "Hello, \(self.myUser.userFirstName)"
        self.monitorMyTeamStatus()
      }
    })
  }

  
  func monitorMyTeamStatus() {
    if myUser.teamID != "" && myUser.teamID != nil {
      Database.database().reference().child("Teams").child(myUser.teamID).child("teaminfo").observeSingleEvent(of: .value, with: { snap in
        if let dict = snap.value as? [String:AnyObject] {
          let team = Team(dict)
          self.checkJoinStatus(team: team,user: self.myUser)
        }
      })
    } else {
      UIView.animate(withDuration: 0.2) {
        self.requestView.alpha = 0
        self.joinBtn.alpha = 1
        self.createBtn.alpha = 1
      }
    }
  }
  
  fileprivate func checkJoinStatus(team: Team,user: User) {
    if user.joinStatus == "private" {
      teamNameLabel.text = team.name
      UIView.animate(withDuration: 0.2) {
        self.requestView.alpha = 1
        self.joinBtn.alpha = 0
        self.createBtn.alpha = 0
      }
    } else {
      self.performSegue(withIdentifier: "joined", sender: self.myUser)
      self.requestView.alpha = 0
      self.joinBtn.alpha = 1
      self.createBtn.alpha = 1
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    teamName.text = ""
    teamPass.text = ""
    if let destination = segue.destination as? CreateTeamVC, let user = sender as? User {
      destination.myUser = user
    }
    if let des = segue.destination as? UINavigationController {
      if let des2 = des.topViewController as? HomeVC, let user = sender as? User {
        des2.myUser = user
      }
    }
    if let dest = segue.destination as? ProfileVC {
      dest.joinedTeam = false
      dest.myUser = myUser
    }
  }
  
}
