//
//  LoginVC.swift
//  MeetingManager
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
  
  @IBAction func loginPressed(_ sender: UIButton) {
    SVProgressHUD.show()
    Auth.auth().signIn(withEmail: emailField.text!, password: passField.text!) {[weak self] (user, error) in
      if error != nil {
        print(error!.localizedDescription)
        self?.displayBasicAlert(title: "Ops", msg: "Please make sure your e-mail and password are correct")
        SVProgressHUD.dismiss()
      } else {
        self?.handleSignIn()
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
    guard let uId = Auth.auth().currentUser?.uid else {return}
    Database.database().reference().child("Users").child(uId).observe(.value, with: { [weak self] (snapshot) in
      if let dictionary = snapshot.value as? [String:AnyObject] {
        let myUser = User(dictionary)
        SVProgressHUD.dismiss()
        if myUser.teamID == "" || myUser.joinStatus == "private" {
          self?.presentingViewController?.dismiss(animated: false, completion: nil)
          self?.performSegue(withIdentifier: "toWelcome", sender: myUser)
        } else {
          self?.dismiss(animated: false, completion: nil)
          self?.performSegue(withIdentifier: "toHome", sender: myUser)
        }
      }
    })
  }
  
  fileprivate func switchBetween() {
    view.endEditing(true)
    let width = view.frame.width
    if signViewLeading.constant == 0 {
      emailResetField.isHidden = false
      UIView.animate(withDuration: 0.3) { [weak self] in
        self?.signViewLeading.constant = width
        self?.resetViewLeading.constant = 0
        self?.emailResetField.text = self?.emailField.text
        self?.view.layoutIfNeeded()
      }
    } else {
      emailResetField.isHidden = true
      UIView.animate(withDuration: 0.3) { [weak self] in
        self?.signViewLeading.constant = 0
        self?.resetViewLeading.constant = -width
        self?.emailResetField.text = self?.emailField.text
        self?.view.layoutIfNeeded()
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
        self.displayBasicAlert(title: "Invalid E-mail", msg: "Please make sure you are using a valid E-mail address.")
      } else {
        let alert = UIAlertController(title: "E-mail sent", message: "Please check your inbox", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self]_ in
          self?.switchBetween()
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

