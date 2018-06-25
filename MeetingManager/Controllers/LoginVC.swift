//
//  LoginVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginVC: UIViewController {
  @IBOutlet weak var signViewLeading: NSLayoutConstraint!
  @IBOutlet weak var resetViewLeading: NSLayoutConstraint!
  @IBOutlet weak var emailResetField: UITextField!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    checkAuth()
    hideNavBar()
  }
  
  @IBAction func loginPressed(_ sender: Any) {
    SVProgressHUD.show()
    Auth.auth().signIn(withEmail: emailField.text!, password: passField.text!) { (user, error) in
      if error != nil {
        print(error!.localizedDescription)
        let alert = UIAlertController(title: "Ops", message: "Please make sure your e-mail and password are correct", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert,animated: true,completion: nil)
        SVProgressHUD.dismiss()
      } else {
        self.handleSignIn()
      }
    }
  }
  
  fileprivate func checkAuth() {
    if Auth.auth().currentUser?.uid != nil {
      SVProgressHUD.show()
      perform(#selector(handleSignIn))
    }
  }
  @objc func handleSignIn() {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
      if let dictionary = snapshot.value as? [String:AnyObject] {
        let myUser = User(data: dictionary)
        SVProgressHUD.dismiss()
        if myUser.teamID == "" {
          self.performSegue(withIdentifier: "toWelcome", sender: myUser)
        } else {
          self.performSegue(withIdentifier: "toHome", sender: myUser)
        }
      }
    })
  }
  
  fileprivate func switchBetween() {
    view.endEditing(true)
    if signViewLeading.constant == 0 {
      emailResetField.isHidden = false
      UIView.animate(withDuration: 0.3) {
        self.signViewLeading.constant = 375
        self.resetViewLeading.constant = 0
        self.emailResetField.text = self.emailField.text
        self.view.layoutIfNeeded()
      }
    } else {
      emailResetField.isHidden = true
      UIView.animate(withDuration: 0.3) {
        self.signViewLeading.constant = 0
        self.resetViewLeading.constant = -375
        self.emailResetField.text = self.emailField.text
        self.view.layoutIfNeeded()
      }
    }
  }

  
  @IBAction func forgotPressed(_ sender: Any) {
    switchBetween()
  }
  
  @IBAction func backtoSign(_ sender: Any) {
    switchBetween()
  }
  
  @IBAction func resetPressed(_ sender: Any) {
    guard let email = emailResetField.text else {return}
    Auth.auth().sendPasswordReset(withEmail: email) { (err) in
      if err != nil {
        print(err!.localizedDescription)
        let alert = UIAlertController(title: "Invalid E-mail", message: "Please make sure you are using a valid E-mail address.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
      } else {
        let alert = UIAlertController(title: "E-mail sent", message: "Please check your inbox", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
          self.switchBetween()
        }))
        self.present(alert, animated: true, completion: nil)
      }
      
    }
  }
  
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination1 = segue.destination as? WelcomeVC, let user1 = sender as? User {
      destination1.myUser = user1
    }
    if let des = segue.destination as? UINavigationController {
      if let des2 = des.topViewController as? HomeVC, let user2 = sender as? User {
        des2.myUser = user2
      }
    }
  }
  
  
}

