//
//  WelcomeVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/27/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase

class WelcomeVC: UIViewController {
    
    @IBOutlet weak var teamPass: UITextField!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var helloLabel: UILabel!
    var myUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helloLabel.text = "Hello, \(myUser.userFirstName)"
    }
    
    @IBAction func signOut() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signedOut", sender: nil)
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func createPressed(_ sender: Any) {
        performSegue(withIdentifier: "CreateTeam", sender: myUser)
    }

    @IBAction func joinPressed(_ sender: Any) {
    Database.database().reference().child("teamRef").observeSingleEvent(of: .value) { (snap) in
    if let children = snap.children.allObjects as? [DataSnapshot] {
    if children.count > 0 {
    for snapshot in children {
    if let dict = snapshot.value as? [String:AnyObject] {
    let team = Team(data: dict)
    if team.name.lowercased() == self.teamName.text! || team.name == self.teamName.text! || team.name.capitalized == self.teamName.text! {
    if team.pass == self.teamPass.text! { // Correct info given
    self.myUser.teamID = team.id
    Database.database().reference().child("Users").child(self.myUser.userID).updateChildValues(["team":team.id])
    let newMember = ["email" :self.myUser.userEmail,"firstname" : self.myUser.userFirstName,"lastname" : self.myUser.userLastName,"city" : self.myUser.userCity,"profilepicURL" : self.myUser.imageURL,"uid" : self.myUser.userID,"position":self.myUser.position,"birth":self.myUser.birth,"country":self.myUser.birth,"phone":self.myUser.phone,"team":team.id]
    Database.database().reference().child("Teams").child(team.id).child("Members").child(self.myUser.userID).setValue(newMember, withCompletionBlock: { (err, ref) in
    self.performSegue(withIdentifier: "joined", sender: self.myUser)
    })
    } else { // Wrong name or Pass
    print("Wrong Name or Pass")
    }
    }
    }
    }
    }
    }
    }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreateTeamVC {
            if let user = sender as? User {
                destination.myUser = user
            }
        }
        if let des = segue.destination as? UINavigationController {
            if let des2 = des.topViewController as? HomeVC {
                if let user = sender as? User {
                    des2.myUser = user
                }
            }
        }
    }

}
