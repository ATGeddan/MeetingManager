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
  
  @IBOutlet weak var membersView: UIView!
  @IBOutlet weak var membersBtn: UIButton!
  @IBOutlet weak var allMemberBtn: UIButton!
  @IBOutlet weak var tableLeading: NSLayoutConstraint!
  @IBOutlet weak var userTableView: UITableView!
  @IBOutlet weak var cityField: UITextField!
  @IBOutlet weak var placeField: UITextField!
  @IBOutlet weak var dateField: UITextField!
  
  var users = [User]()
  var chosenUsers = [String]()
  var myUser = User()
  lazy var picker = UIDatePicker()
  var formatDate = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    getUsers()
    createDateTimePicker()
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    Database.database().reference().child("Teams").child(myUser.teamID).child("Members").removeAllObservers()
  }
  
  @IBAction func allPressed(_ sender: UIButton) {
    self.view.endEditing(true)
    let width = view.frame.width
    if tableLeading.constant == 0 {
      UIView.animate(withDuration: 0.3) {
        self.tableLeading.constant = -width - 5
        self.membersView.alpha = 0
        self.view.layoutIfNeeded()
      }
    }
    chosenUsers = []
    allMemberBtn.setImage(#imageLiteral(resourceName: "buttonOn"), for: .normal)
    membersBtn.setImage(#imageLiteral(resourceName: "buttonOff"), for: .normal)
    for user in users {
      chosenUsers.append(user.userID)
    }
    
  }
  
  @IBAction func specificPressed(_ sender: UIButton) {
    self.view.endEditing(true)
    let width = view.frame.width
    if tableLeading.constant == -width - 5 {
      allMemberBtn.setImage(#imageLiteral(resourceName: "buttonOff"), for: .normal)
      membersBtn.setImage(#imageLiteral(resourceName: "buttonOn"), for: .normal)
      self.chosenUsers = []
      let selectedItems = userTableView.indexPathsForSelectedRows
      if selectedItems != nil {
        for x in selectedItems! {
          userTableView.deselectRow(at: x, animated: true)
          if let cell = userTableView.cellForRow(at: x) {
            let view = UIImageView(image: #imageLiteral(resourceName: "check"))
            cell.accessoryView = view
          }
        }
      }
      
      UIView.animate(withDuration: 0.3) {
        self.tableLeading.constant = 0
        self.membersView.alpha = 1
        self.view.layoutIfNeeded()
      }
    }
    
    
  }
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = userTableView.dequeueReusableCell(withIdentifier: "userCell0", for: indexPath) as! userCell0
    let theUser = users[indexPath.row]
    cell.userName.text = theUser.userFirstName + " " + theUser.userLastName
    let view = UIImageView(image: #imageLiteral(resourceName: "check"))
    cell.accessoryView = view
    return cell
  }
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = users[indexPath.row].userID
    chosenUsers.append(item)
    
    if let cell = tableView.cellForRow(at: indexPath) {
      let view = UIImageView(image: #imageLiteral(resourceName: "checked"))
      cell.accessoryView = view
    }
  }
  
  internal func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let item = users[indexPath.row].userID
    if let index = chosenUsers.index(where: {$0 == item}) {
      chosenUsers.remove(at: index)
    }
    if let cell = tableView.cellForRow(at: indexPath) {
      let view = UIImageView(image: #imageLiteral(resourceName: "check"))
      cell.accessoryView = view
    }
  }
  
  fileprivate func getUsers() {
    membersView.alpha = 0
    tableLeading.constant = -view.frame.width - 5
    let teamRef = Database.database().reference().child("Teams").child(myUser.teamID).child("Members")
    teamRef.observe(.childAdded) { (snapshot) in
      if let dictionary0 = snapshot.value as? [String:AnyObject] {
        let user = User(dictionary0)
        self.users.append(user)
        self.userTableView.reloadData()
      }
    }
    
  }
  
  @objc fileprivate func donePressed() {
    if dateField.text != "" && placeField.text != "" && cityField.text != "" && chosenUsers != [] {
      for chosenUser in chosenUsers {
        let teamRef = Database.database().reference().child("Teams").child(myUser.teamID).child("NextMeeting")
        teamRef.child(chosenUser).removeValue()
        let autoID = Int(NSDate.timeIntervalSinceReferenceDate*1000)
        let new = ["date":dateField.text!,
                   "place":placeField.text!,
                   "city":cityField.text!,
                   "ID": "\(autoID)",
                   "formatDate":formatDate,
                   "seen":"false"]
        teamRef.child(chosenUser).updateChildValues(new)
      }
      navigationController?.popViewController(animated: true)
    }
  }
  
  fileprivate func createDateTimePicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneWithDateTime))
    toolbar.setItems([done], animated: true)
    toolbar.tintColor = UIColor.darkGray
    dateField.inputAccessoryView = toolbar
    dateField.inputView = picker
    picker.datePickerMode = .dateAndTime
  }
  
  @objc fileprivate func doneWithDateTime() {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    let dateString = formatter.string(from: picker.date)
    
    let dateFormatter2 = DateFormatter()
    dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
    let dateString2 = dateFormatter2.string(from: picker.date)
    formatDate = dateString2
    
    dateField.text = dateString
    self.view.endEditing(true)
  }
  
}
