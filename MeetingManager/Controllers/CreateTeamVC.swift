//
//  CreateTeamVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/27/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreateTeamVC: UIViewController,UITextFieldDelegate {
  
  @IBOutlet weak var confirmField: UITextField!
  @IBOutlet weak var correctImg: UIImageView!
  @IBOutlet weak var wrongImg: UIImageView!
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
    confirmField.delegate = self
    passField.delegate = self
    
    getTeamNames()
  }
  
  @IBAction func createPressed(_ sender: Any) {
    if nameField.text != "" && nameAvailable == true {
      if passField.text != "" && confirmField.text == passField.text {
        SVProgressHUD.show()
        let teamNewID = Database.database().reference().child("Teams").childByAutoId().key
        let teamDict = ["name":nameField.text!,
                        "password":passField.text!,
                        "org":orgField.text!,
                        "country":countryField.text!,
                        "info":infoField.text!,
                        "adminID":myUser.userID,
                        "id":teamNewID,
                        "adminName":myUser.userFirstName + " " + myUser.userLastName]
        myUser.teamID = teamNewID
        let teamRef = ["name":nameField.text!,"password":passField.text!,"id":teamNewID]
        Database.database().reference().child("teamRef").child(teamNewID).setValue(teamRef)
        Database.database().reference().child("Teams").child(teamNewID).child("teaminfo").setValue(teamDict)
        Database.database().reference().child("Users").child(myUser.userID).updateChildValues(["team":teamNewID])
        let newMember = ["email" :myUser.userEmail,
                         "firstname" : myUser.userFirstName,
                         "lastname" : myUser.userLastName,
                         "city" : myUser.userCity,
                         "profilepicURL" : myUser.imageURL,
                         "uid" : myUser.userID,
                         "position":myUser.position,
                         "birth":myUser.birth,
                         "country":myUser.birth,
                         "phone":myUser.phone,
                         "team":teamNewID]
        Database.database().reference().child("Teams").child(teamNewID).child("Members").child(myUser.userID).setValue(newMember) { (err, ref) in
          if err == nil {
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "created", sender: self.myUser)
          } else {
            print(err!.localizedDescription)
          }
        }
      } else { // pass error msg
        self.displayBasicAlert(title: "Ops", msg: "Please make sure your passwords match and not Empty")
      }
    } else {     // name error msg
      self.displayBasicAlert(title: "Ops", msg: "Please make sure you are using an available name")
    }
  }
  
  @IBAction func backPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  
  fileprivate func getTeamNames() {
    Database.database().reference().child("teamRef").observeSingleEvent(of: .value) { (snap) in
      if let teams = snap.children.allObjects as? [DataSnapshot] {
        for team in teams {
          if let dict = team.value as? [String:AnyObject], let teamName = dict["name"] as? String {
            self.teamNames.append(teamName)
          }
        }
      }
    }
  }
  
  internal func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.tag == 1 {
      nameAvailable = true
      nameUseLabel.isHidden = true
    }
    if textField.tag == 2 {
      wrongImg.isHidden = true
      correctImg.isHidden = true
    }
  }
  
  internal func textFieldDidEndEditing(_ textField: UITextField) {
    if textField.tag == 1 {
      for name in teamNames {
        if nameField.text == name.lowercased() || nameField.text == name.capitalized || nameField.text == name {
          self.nameAvailable = false
          self.nameUseLabel.isHidden = false
        }
      }
    }
    if textField.tag == 2 {
      checkConfirmPass()
    }
  }
  
  fileprivate func checkConfirmPass() {
    if passField.text != "" {
      if confirmField.text == passField.text {
        wrongImg.isHidden = true
        correctImg.isHidden = false
      } else {
        wrongImg.isHidden = false
        correctImg.isHidden = true
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let des = segue.destination as? UINavigationController {
      if let des2 = des.topViewController as? HomeVC, let user = sender as? User {
        des2.myUser = user
      }
    }
  }
  
}

