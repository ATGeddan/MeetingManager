//
//  RegisterVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterVC: UIViewController,UITextFieldDelegate {
  @IBOutlet weak var correct: UIImageView!
  @IBOutlet weak var wrong: UIImageView!
  @IBOutlet weak var confirmField: UITextField!
  @IBOutlet weak var birthField: UITextField!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passField: UITextField!
  @IBOutlet weak var firstField: UITextField!
  @IBOutlet weak var lastField: UITextField!
  
  lazy var picker = UIDatePicker()
  var myUser = User()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createDatePicker()
    confirmField.delegate = self
    passField.delegate = self
    
  }
  
  internal func textFieldDidBeginEditing(_ textField: UITextField) {
    correct.isHidden = true
    wrong.isHidden = true
  }
  
  internal func textFieldDidEndEditing(_ textField: UITextField) {
    if passField.text != "" && confirmField.text == passField.text {
      correct.isHidden = false
      wrong.isHidden = true
    } else {
      correct.isHidden = true
      wrong.isHidden = false
      }
    
  }
  
  @IBAction func registerPressed(_ sender: Any) {
    guard let email = emailField.text ,let password = passField.text else { return }
    if passField.text == confirmField.text && firstField.text?.isEmpty == false && lastField.text?.isEmpty == false {
      SVProgressHUD.show()
      Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
        if error != nil {
          if let errCode = AuthErrorCode(rawValue: error!._code) {
            
            switch errCode {
            case .invalidEmail:
              self.displayBasicAlert(title: "Invalid E-mail", msg: "Please check the entered email address")
              
            case .emailAlreadyInUse:
              self.displayBasicAlert(title: "E-mail already used", msg: "This e-mail has already signed up")
              
            case .weakPassword:
              self.displayBasicAlert(title: "Weak Password", msg: "Make sure password is more than 6 characters")
              
            default:
              print("Other error!")
            }
            
          }
        } else {
          self.createProfile()
          SVProgressHUD.dismiss()
          self.performSegue(withIdentifier: "registered", sender: self.myUser)
        }
      }
    } else {
      self.displayBasicAlert(title: "Ops", msg: "Please make sure all fields have correct information")
    }
  }
  
  fileprivate func createProfile() {
    let userDB = Database.database().reference().child("Users")
    let defultPicURL = "https://firebasestorage.googleapis.com/v0/b/meetingmanager-b8254.appspot.com/o/default.png?alt=media&token=d8396756-dfc8-4d90-8cc7-b28d723afdae"
    guard let uid = Auth.auth().currentUser?.uid else {return}
    let userDictionary : [String: String] = ["email" : emailField.text!,
                                             "firstname" : firstField.text!,
                                             "lastname" : lastField.text!,
                                             "city" : "",
                                             "profilepicURL" : defultPicURL,
                                             "uid" : uid,
                                             "position":"",
                                             "birth":birthField.text!,
                                             "country":"",
                                             "phone":""]
    let user = User(data: userDictionary as [String:AnyObject])
    myUser = user
    userDB.child(uid).setValue(userDictionary){
      (error, reference) in
      if error != nil {
        print(error!.localizedDescription)
      }
    }
    
  }
  
  fileprivate func createDatePicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneWithDate))
    toolbar.setItems([done], animated: true)
    toolbar.tintColor = UIColor.darkGray
    birthField.inputAccessoryView = toolbar
    birthField.inputView = picker
    picker.datePickerMode = .date
  }
  
  @objc func doneWithDate() {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    let dateString = formatter.string(from: picker.date)
    birthField.text = dateString
    self.view.endEditing(true)
  }
  

  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let des = segue.destination as? WelcomeVC, let user = sender as? User {
      des.myUser = user
    }
  }
  
}
