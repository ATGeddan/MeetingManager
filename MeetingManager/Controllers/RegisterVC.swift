//
//  RegisterVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var firstField: UITextField!
    @IBOutlet weak var lastField: UITextField!
    let picker = UIDatePicker()
    var myUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

    }


    @IBAction func registerPressed(_ sender: Any) {
        guard let email = emailField.text ,let password = passField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.errorLabel.isHidden = false
                print(error!)
            } else {
                self.createProfile()
                self.errorLabel.isHidden = true
                self.performSegue(withIdentifier: "registered", sender: self.myUser)
            }
        }
    }
    
    func createProfile() {
        let userDB = Database.database().reference().child("Users")
        let defultPicURL = "https://firebasestorage.googleapis.com/v0/b/meetingmanager-b8254.appspot.com/o/default.png?alt=media&token=d8396756-dfc8-4d90-8cc7-b28d723afdae"
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userDictionary : [String: String] = ["email" : emailField.text!,"firstname" : firstField.text!,"lastname" : lastField.text!,"city" : "","profilepicURL" : defultPicURL,"uid" : uid,"position":"","birth":birthField.text!,"country":"","phone":""]
        let user = User(data: userDictionary as Dictionary<String, AnyObject>)
        myUser = user
        userDB.child(uid).setValue(userDictionary){
            (error, reference) in
            if error != nil {
                
                print(error!)
            }
        }
        
    }
    
    func createDatePicker() {
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
        if let des = segue.destination as? WelcomeVC {
            if let user = sender as? User {
                des.myUser = user
            }
        }
    }

}
