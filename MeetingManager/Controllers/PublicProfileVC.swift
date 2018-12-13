//
//  PublicProfileVC.swift
//  MeetingManager
//
//  Created by Ahmed Eltabbal on 5/14/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher



class PublicProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource,XMSegmentedControlDelegate {
  
  @IBOutlet weak var segmentBG: UIImageView!
  @IBOutlet weak var taskPlaceHolder: UIView!
  @IBOutlet weak var tasksView: UIView!
  @IBOutlet weak var removeBtn: UIButton!
  @IBOutlet weak var makeAdminBtn: UIButton!
  @IBOutlet weak var birthLabel: UILabel!
  @IBOutlet weak var completedNumber: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var countryLabel: UILabel!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var taskNumber: UILabel!
  @IBOutlet weak var positionLabel: UILabel!
  @IBOutlet weak var numberOfTasks: UILabel!
  @IBOutlet weak var tasksTable: UITableView!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var profilePic: UIImageView!
  
  var selectedUser = User()
  var myUser = User()
  var myTeam = Team()
  var tasks = [Task]()
  var completedTasks = 0
  
  var delegate:adminActions?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpProfile()
    updateTasks()
    setupSegmentedController()
    
    if myUser.userID == myTeam.adminID && selectedUser.userID != myTeam.adminID && selectedUser.joinStatus == "default" {
      makeAdminBtn.isHidden = false
      removeBtn.isHidden = false
    }
  }
  
  @IBAction func confirmAdmin(sender: UIButton) {
    let alert = UIAlertController(title: "Are You Sure?", message: "Do you want to make \(selectedUser.userFirstName) the team admin?", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { action in
      self.changeAdmin()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func confirmRemove(sender: UIButton) {
    let alert = UIAlertController(title: "Are You Sure?", message: "Do you want to remove \(selectedUser.userFirstName) from the team?", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.destructive, handler: { action in
      self.removeMember()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }

  
  fileprivate func changeAdmin() {
    delegate?.didChangeAdmin(id: selectedUser.userID)
    let teamRef = Database.database().reference().child("Teams").child(myTeam.id)
    teamRef.child("teaminfo").updateChildValues(["adminID":selectedUser.userID,"adminName":selectedUser.userFirstName+" "+selectedUser.userLastName])
    teamRef.child("Meetings").observeSingleEvent(of: .value) { (snap) in
      if let meetings = snap.children.allObjects as? [DataSnapshot] {
        for meeting in meetings {
          if let dict = meeting.value as? [String:AnyObject] {
            let meeting = MeetingModel(dict)
            teamRef.child("Meetings").child(meeting.meetingID).updateChildValues(["teamAdmin":self.selectedUser.userID])
          }
        }
        self.makeAdminBtn.isHidden = true
        self.removeBtn.isHidden = true
        self.myTeam.updateAdmin(id:self.selectedUser.userID)
        Database.database().reference().child("Teams").child(self.myUser.teamID).child("NewRequests").removeAllObservers()
        self.tasksTable.reloadData()
      }
    }
  }
  
  fileprivate func removeMember() {
    let teamRef = Database.database().reference().child("Teams").child(myTeam.id)
    teamRef.child("UserTasks").child(selectedUser.userID).removeValue()
    Database.database().reference().child("Users").child(selectedUser.userID).updateChildValues(["team":""])
    teamRef.child("Members").child(selectedUser.userID).removeValue { (err, ref) in
      if err == nil {
        self.delegate?.didRemoveMember()
      }
    }
    navigationController?.popViewController(animated: true)
  }
  
  fileprivate func setupSegmentedController() {
    infoView.alpha = 0
    let segmentedControl2 = XMSegmentedControl(frame: CGRect(x: 0, y: 375, width: self.view.frame.width, height: 44),
                                               segmentTitle: ["Tasks", "Info"],
                                               selectedItemHighlightStyle: XMSelectedItemHighlightStyle.bottomEdge)
    segmentedControl2.delegate = self
    segmentedControl2.backgroundColor = UIColor.clear
    segmentedControl2.highlightColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
    segmentedControl2.tint = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.7)
    segmentedControl2.highlightTint = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    segmentedControl2.addShadow(location: .top, color: UIColor.darkGray, opacity: 0.5, radius: 3.0)
    
    self.view.addSubview(segmentedControl2)
    let width = view.frame.width
    segmentedControl2.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint(item: segmentedControl2,
                       attribute: NSLayoutConstraint.Attribute.centerX,
                       relatedBy: NSLayoutConstraint.Relation.equal,
                       toItem: segmentBG, attribute: NSLayoutConstraint.Attribute.centerX,
                       multiplier: 1,
                       constant: 0).isActive = true
    
    NSLayoutConstraint(item: segmentedControl2,
                       attribute: NSLayoutConstraint.Attribute.topMargin,
                       relatedBy: NSLayoutConstraint.Relation.equal,
                       toItem: segmentBG, attribute: NSLayoutConstraint.Attribute.topMargin,
                       multiplier: 1,
                       constant: 7).isActive = true
    NSLayoutConstraint(item: segmentedControl2,
                       attribute: NSLayoutConstraint.Attribute.width,
                       relatedBy: NSLayoutConstraint.Relation.equal,
                       toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                       multiplier: 1,
                       constant: width).isActive = true
    NSLayoutConstraint(item: segmentedControl2,
                       attribute: NSLayoutConstraint.Attribute.height,
                       relatedBy: NSLayoutConstraint.Relation.equal,
                       toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                       multiplier: 1,
                       constant: 44).isActive = true
  }
  
  internal func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
    if selectedSegment == 0 {
      UIView.animate(withDuration: 0.2, animations: {
        self.tasksView.alpha = 1
        self.infoView.alpha = 0
      })
    } else if selectedSegment == 1 {
      UIView.animate(withDuration: 0.2, animations: {
        self.tasksView.alpha = 0
        self.infoView.alpha = 1
      })
    }
  }
  
  fileprivate func setUpProfile() {
    cityLabel.text = selectedUser.userCity
    nameLabel.text = selectedUser.userFirstName + " " + selectedUser.userLastName
    positionLabel.text = selectedUser.position
    phoneLabel.text = selectedUser.phone
    countryLabel.text = selectedUser.country
    emailLabel.text = selectedUser.userEmail
    birthLabel.text = selectedUser.birth
    let url = URL(string: selectedUser.imageURL)
    profilePic.kf.setImage(with: url)
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
    profilePic.layer.borderWidth = 3.5
    profilePic.layer.borderColor = UIColor(red: 156/255, green: 156/255, blue: 156/255, alpha: 1).cgColor
    self.title = "PROFILE"
  }
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count:Int!
    if tasks.count > 0 {
      count = tasks.count
      taskPlaceHolder.isHidden = true
    } else {
      count = 0
      taskPlaceHolder.isHidden = false
    }
    return count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tasksTable.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! profileCell
    if tasks.count > 0 {
      let task = tasks[indexPath.row]
      cell.configProfileCell(task)
      cell.checkTaskStatus(task: task, table: tableView, indexPath: indexPath)
      
      let myID = myUser.userID
      if myID == myTeam.adminID {
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.isHidden = false
      } else {
        cell.deleteBtn.isHidden = true
      }
    }
    return cell
  }
  
  internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65.0
  }
  
  fileprivate func updateCount(){
    completedNumber.text = "\(completedTasks)"
  }
  
  @IBAction func deleteTaskClicked(_ sender: UIButton) {
    let alert = UIAlertController(title: "Delete?", message: "Do you want to save or delete this task?", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
      self.confirmDelete(sender)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  fileprivate func confirmDelete(_ sender:UIButton) {
    let teamRef = Database.database().reference().child("Teams").child(myTeam.id)
    teamRef.child("NewTasks").child(selectedUser.userID).child(tasks[sender.tag].ID).removeValue()
    teamRef.child("UserTasks").child(selectedUser.userID).child(tasks[sender.tag].ID).removeValue()
  }
  
  fileprivate func retrieveTasks() {
    Database.database().reference().child("Teams").child(selectedUser.teamID).child("UserTasks").child(selectedUser.userID).observeSingleEvent(of: .value) { (snapshot) in
      self.tasks = []
      self.completedTasks = 0
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        for child in children {
          if let dict = child.value as? [String:AnyObject] {
            let task = Task(dict)
            self.tasks.append(task)
            self.tasksTable.reloadData()
            if task.done {
              self.completedTasks += 1
            }
            self.numberOfTasks.text = "\(self.tasks.count)"
            self.updateCount()
          }
        }
      }
    }
  }
  
  fileprivate func updateTasks() {
    let teamRef = Database.database().reference().child("Teams").child(myTeam.id)
    teamRef.child("UserTasks").child(selectedUser.userID).observe(.value) { _ in
      self.tasks = []
      self.completedTasks = 0
      self.retrieveTasks()
      self.tasksTable.reloadData()
    }
    teamRef.child("UserTasks").child(selectedUser.userID).observe(.childRemoved) { _ in
      self.tasks = []
      self.completedTasks = 0
      self.retrieveTasks()
      self.tasksTable.reloadData()
      self.numberOfTasks.text = "\(self.tasks.count)"
      self.updateCount()
    }
  }
  
}
