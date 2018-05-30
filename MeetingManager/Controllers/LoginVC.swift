//
//  LoginVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuth()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }

    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailField.text!, password: passField.text!) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("success loging in")
                if let uid = Auth.auth().currentUser?.uid {
                Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        let myUser1 = User(data: dictionary)
                        if myUser1.teamID == nil || myUser1.teamID == "" {
                            self.performSegue(withIdentifier: "toWelcome", sender: myUser1)
                        } else {
                            self.performSegue(withIdentifier: "toHome", sender: myUser1)
                        }
                    }
                })
                
                }
            }
    }
    }
    
    func checkAuth() {
        if Auth.auth().currentUser?.uid != nil {
            perform(#selector(handleSignIn))
        }
    }
    @objc func handleSignIn() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let myUser1 = User(data: dictionary)
                if myUser1.teamID == nil || myUser1.teamID == "" {
                    self.performSegue(withIdentifier: "toWelcome", sender: myUser1)
                } else {
                    self.performSegue(withIdentifier: "toHome", sender: myUser1)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination1 = segue.destination as? WelcomeVC {
            if let user1 = sender as? User {
                destination1.myUser = user1
            }
        }
        if let des = segue.destination as? UINavigationController {
            if let des2 = des.topViewController as? HomeVC {
            if let user2 = sender as? User {
                des2.myUser = user2
            }
            }
        }
    }


}

