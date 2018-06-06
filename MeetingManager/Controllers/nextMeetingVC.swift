//
//  nextMeetingVC.swift
//  MeetingManager
//
//  Created by Ahmed Eltabbal on 6/6/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase

class nextMeetingVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    var users = [User]()
    var chosenUsers = [String]()
    var myUser = User()
    let picker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableBottom.constant = 288
        getUsers()
        createDatePicker()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
    }
    
    

    @IBAction func allPressed(_ sender: Any) {
        if tableBottom.constant == 0 {
            UIView.animate(withDuration: 0.3) {
                self.tableBottom.constant = 288
                self.view.layoutIfNeeded()
            }
        }
        chosenUsers = []
        for user in users {
            chosenUsers.append(user.userID)
        }

    }
    
    @IBAction func specificPressed(_ sender: Any) {
        
        if tableBottom.constant == 288 {
            self.chosenUsers = []
            let selectedItems = userTableView.indexPathsForSelectedRows
            if selectedItems != nil {
                for x in selectedItems! {
                    userTableView.deselectRow(at: x, animated: true)
                    if let cell = userTableView.cellForRow(at: x) {
                        let view = UIImageView(image: UIImage(named: "check"))
                        cell.accessoryView = view
                    }
                }
            }
            
            UIView.animate(withDuration: 0.3) {
                self.tableBottom.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userTableView.dequeueReusableCell(withIdentifier: "userCell0", for: indexPath) as! userCell0
        cell.userName.text = users[indexPath.row].userFirstName + " " + users[indexPath.row].userLastName
        let view = UIImageView(image: UIImage(named: "check"))
        cell.accessoryView = view
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = users[indexPath.row].userID
        chosenUsers.append(item)
    
        if let cell = tableView.cellForRow(at: indexPath) {
            let view = UIImageView(image: UIImage(named: "checked"))
            cell.accessoryView = view
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item = users[indexPath.row].userID
        if let index = chosenUsers.index(where: {$0 == item}) {
            chosenUsers.remove(at: index)
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            let view = UIImageView(image: UIImage(named: "check"))
            cell.accessoryView = view
        }
    }
    
    func getUsers() {
        let teamRef = Database.database().reference().child("Teams").child(myUser.teamID).child("Members")
        teamRef.observe(.childAdded) { (snapshot) in
            if let dictionary0 = snapshot.value as? [String:AnyObject] {
                let user = User(data: dictionary0)
                self.users.append(user)
                self.userTableView.reloadData()
            }
        }
        
    }
    
    @objc func donePressed() {
        if dateField.text != "" && placeField.text != "" && cityField.text != "" && chosenUsers != [] {
        for chosenUser in chosenUsers {
            let teamRef = Database.database().reference().child("Teams").child(myUser.teamID).child("NextMeeting")
            let autoID = Int(NSDate.timeIntervalSinceReferenceDate*1000)
            let new = ["date":dateField.text!,
                       "place":placeField.text!,
                       "city":cityField.text!,
                       "ID":"\(autoID)"]
            teamRef.child(chosenUser).child("\(autoID)").updateChildValues(new)
        }
        navigationController?.popViewController(animated: true)
        }
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneWithDate))
        toolbar.setItems([done], animated: true)
        toolbar.tintColor = UIColor.darkGray
        dateField.inputAccessoryView = toolbar
        dateField.inputView = picker
        picker.datePickerMode = .dateAndTime
    }
    
    @objc func doneWithDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: picker.date)
        dateField.text = dateString
        self.view.endEditing(true)
    }
    
}
