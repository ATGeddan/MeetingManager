//
//  CreateTeamVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/27/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase

class CreateTeamVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var nameUseLabel: UILabel!
    @IBOutlet weak var infoField: UITextView!
    @IBOutlet weak var orgField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    var myUser = User()
    var teamNames = [String]()
    var nameAvailable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        getTeamNames()
    }

    @IBAction func createPressed(_ sender: Any) {
        if nameField.text != "" && passField.text != "" && nameAvailable == true {
            let teamID = Int(NSDate.timeIntervalSinceReferenceDate*1000)
            let teamDict = ["name":nameField.text!,"password":passField.text!,"org":orgField.text!,"country":countryField.text!,"info":infoField.text!,"adminID":myUser.userID,"id":"t\(teamID)","adminName":myUser.userFirstName + " " + myUser.userLastName]
            myUser.teamID = "t\(teamID)"
            let teamRef = ["name":nameField.text!,"password":passField.text!,"id":"t\(teamID)"]
            Database.database().reference().child("teamRef").child("t\(teamID)").setValue(teamRef)
            Database.database().reference().child("Teams").child("t\(teamID)").child("teaminfo").setValue(teamDict)
            Database.database().reference().child("Users").child(myUser.userID).updateChildValues(["team":"t\(teamID)"])
            let newMember = ["email" :myUser.userEmail,"firstname" : myUser.userFirstName,"lastname" : myUser.userLastName,"city" : myUser.userCity,"profilepicURL" : myUser.imageURL,"uid" : myUser.userID,"position":myUser.position,"birth":myUser.birth,"country":myUser.birth,"phone":myUser.phone,"team":"t\(teamID)"]
            Database.database().reference().child("Teams").child("t\(teamID)").child("Members").child(myUser.userID).setValue(newMember) { (err, ref) in
                if err == nil {
                    self.performSegue(withIdentifier: "created", sender: self.myUser)
                } else {
                    print(err!)
                }
            }
            
        } else {     // error msg 
            let alert = UIAlertController(title: "Ops", message: "Please take a second look at the team name and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert,animated: true,completion: nil)
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? UINavigationController {
            if let des2 = des.topViewController as? HomeVC {
                if let user = sender as? User {
                    des2.myUser = user
                }
            }
        }
    }
    
    func getTeamNames() {
        Database.database().reference().child("teamRef").observeSingleEvent(of: .value) { (snap) in
            if let teams = snap.children.allObjects as? [DataSnapshot] {
                for i in 0..<teams.count {
                    if let dict = teams[i].value as? [String:AnyObject] {
                        let teamName = dict["name"] as! String
                        self.teamNames.append(teamName)
                    }
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for x in 0..<teamNames.count {
            if nameField.text?.lowercased() == teamNames[x] || nameField.text?.capitalized == teamNames[x] || nameField.text == teamNames[x] {
                self.nameAvailable = false
                self.nameUseLabel.isHidden = false
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameAvailable = true
        nameUseLabel.isHidden = true
    }
    
}

