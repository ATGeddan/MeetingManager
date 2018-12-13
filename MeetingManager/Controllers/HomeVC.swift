//
//  HomeVC.swift
//  MeetingManager
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SVProgressHUD



class HomeVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
  
  @IBOutlet weak var changeJoinStatus: UIButton!
  @IBOutlet weak var notifBubble4: UIImageView!
  @IBOutlet weak var notifLabel4: UILabel!
  @IBOutlet weak var confirmPassBtn: UIButton!
  @IBOutlet weak var nextNotifLabel: UILabel!
  @IBOutlet weak var notifBubble3: UIImageView!
  @IBOutlet weak var cellPlaceHolder: UIView!
  @IBOutlet weak var cancelBtn: UIButton!
  @IBOutlet weak var nextMCity: UILabel!
  @IBOutlet weak var nextMPlace: UILabel!
  @IBOutlet weak var nextMDate: UILabel!
  @IBOutlet weak var nextMeetingLeading: NSLayoutConstraint!
  @IBOutlet weak var newTaskNumber2: UILabel!
  @IBOutlet weak var notifBubble2: UIImageView!
  @IBOutlet weak var newTaskNumber: UILabel!
  @IBOutlet weak var notifBubble: UIImageView!
  @IBOutlet weak var confirmField: UITextField!
  @IBOutlet weak var newPassField: UITextField!
  @IBOutlet weak var oldPassField: UITextField!
  @IBOutlet weak var viewTop: NSLayoutConstraint!
  @IBOutlet weak var passView: UIView!
  @IBOutlet weak var changePassBtn: UIButton!
  @IBOutlet weak var teamView: UIView!
  @IBOutlet weak var editTeamBtn: UIButton!
  @IBOutlet weak var teamOrg: UILabel!
  @IBOutlet weak var teamCountry: UILabel!
  @IBOutlet weak var teamName: UILabel!
  @IBOutlet weak var sideEmail: UILabel!
  @IBOutlet weak var sideName: UILabel!
  @IBOutlet weak var sideImage: UIImageView!
  @IBOutlet weak var sideMenu: UIView!
  @IBOutlet weak var menuLeading: NSLayoutConstraint!
  @IBOutlet weak var tableView: UITableView!
  
  var meetings = [MeetingModel]()
  var myUser = User()
  var team = Team()
  var taskNumber:Int!
  var nextID:String!
  var nextMeetingSeen = true
  var newTasksSeen = true
  var requestsSeen = true
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getPersonalInfo()
    setUpSideMenu()
    checkAuth()
    updateMeetings()
    getTeamData()
    checkNextMeeting()
    
    hideNavBar()
  }
  
  
  fileprivate func setUpSideMenu() {
    menuLeading.constant = -222
    nextMeetingLeading.constant = -200
    sideMenu.layer.cornerRadius = 5
    sideImage.layer.borderWidth = 1
    sideImage.layer.borderColor = UIColor.gray.cgColor
    sideMenu.addShadow(location: .right, color: UIColor.black, opacity: 0.8, radius: 3.0)
  }
  
  // MARK: Table view Methods :
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count :Int!
    if meetings.count == 0 {
      cellPlaceHolder.layer.cornerRadius = 5
      cellPlaceHolder.isHidden = false
      count = 0
    } else {
      cellPlaceHolder.layer.cornerRadius = 5
      cellPlaceHolder.isHidden = true
      count = meetings.count
    }
    return count
  }
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? homeCell
    let meeting = meetings[indexPath.row]
    cell?.updatehomeCell(meeting)
    cell?.cellBubble.addShadow(location: .bottom, color: UIColor.black, opacity: 0.3, radius: 0.5)
    return cell!
  }
  
  internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 74.0
  }
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let meetingmodel = meetings[indexPath.row]
    performSegue(withIdentifier: "toMeeting", sender: meetingmodel)
  }
  
  
  // MARK: Getting Meetings info & User info
  
  fileprivate func getMeetings() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("Meetings").observeSingleEvent(of: .value) {[weak self] (snapshot) in
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        self?.meetings = []
        for child in children {
          if let dict = child.value as? [String:AnyObject] {
            let model = MeetingModel(dict)
            self?.meetings.insert(model, at: 0)
            self?.tableView.reloadData()
          }
        }
      }
    }
  }
  
  fileprivate func updateMeetings() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("Meetings").observe(.value) {[weak self] (snap) in
      self?.meetings = []
      self?.getMeetings()
      self?.tableView.reloadData()
    }
    Database.database().reference().child("Teams").child(myUser.teamID).child("Meetings").observe(.childRemoved) {[weak self] (snap) in
      self?.meetings = []
      self?.getMeetings()
      self?.tableView.reloadData()
    }
  }
  
  fileprivate func getPersonalInfo() {
    guard let myID = Auth.auth().currentUser?.uid else {return}
    Database.database().reference().child("Users").child(myID).removeAllObservers()
    Database.database().reference().child("Users").child(myID).observe(.value, with: {[weak self] (snapshot) in
      if let dicts = snapshot.value as? [String:AnyObject] {
        self?.myUser.updateUser(dicts)
        if self?.myUser.teamID != "" {
          let image = URL(string: (self?.myUser.imageURL)!)
          self?.sideImage.kf.setImage(with: image)
          self?.sideName.text = (self?.myUser.userFirstName)! + " " + (self?.myUser.userLastName)!
          self?.sideEmail.text = self?.myUser.userEmail
        } else {
          let alert = UIAlertController(title: "Removed", message: "You have been kicked from this team or the team itself is deleted", preferredStyle: UIAlertController.Style.alert)
          alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
            self?.myUser.teamID = ""
            self?.performSegue(withIdentifier: "backWelcome", sender: nil)
          }))
          self?.navigationController?.popToRootViewController(animated: true)
          self?.present(alert, animated: true, completion: nil)
        }
      }
    })
    
  }
  
  fileprivate func checkNewTasks() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("NewTasks").child(myUser.userID).observeSingleEvent(of: .value) {[weak self] (snap) in
      if let children = snap.children.allObjects as? [DataSnapshot] {
        if children.count > 0 {
          self?.taskNumber = children.count
          self?.newTasksSeen = false
          self?.checkNotifToggle()
          self?.newTaskNumber2.text = String(children.count)
          self?.notifBubble2.isHidden = false
          self?.newTaskNumber2.isHidden = false
        } else {
          self?.newTasksSeen = true
          self?.checkNotifToggle()
          self?.notifBubble2.isHidden = true
          self?.newTaskNumber2.isHidden = true
        }
      }
    }
  }
  
  fileprivate func checkNewRequests() {
    if myUser.userID == team.adminID {
      Database.database().reference().child("Teams").child(myUser.teamID).child("NewRequests").observeSingleEvent(of: .value) {[weak self] snap in
        if let children = snap.children.allObjects as? [DataSnapshot] {
          if children.count > 0 {
            self?.requestsSeen = false
            self?.checkNotifToggle()
          } else {
            self?.requestsSeen = true
            self?.checkNotifToggle()
          }
        }
      }
    }
  }
  
  fileprivate func updateNotifs() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("NewTasks").child(myUser.userID).observe(.childAdded) {[weak self] _ in
      self?.checkNewTasks()
    }
    Database.database().reference().child("Teams").child(myUser.teamID).child("NewTasks").child(myUser.userID).observe(.childRemoved) { [weak self]_ in
      self?.taskNumber = 0
      self?.checkNewTasks()
    }
    if myUser.userID == team.adminID {
      Database.database().reference().child("Teams").child(myUser.teamID).child("NewRequests").observe(.childAdded) {[weak self] _ in
        self?.checkNewRequests()
      }
      Database.database().reference().child("Teams").child(myUser.teamID).child("NewRequests").observe(.childRemoved) { [weak self]_ in
        self?.checkNewRequests()
      }
    }
  }
  
  fileprivate func checkNotifToggle() {
    if !nextMeetingSeen || !newTasksSeen || !requestsSeen {
      notifBubble.isHidden = false
      newTaskNumber.isHidden = false
    } else {
      notifBubble.isHidden = true
      newTaskNumber.isHidden = true
    }
  }
  
  fileprivate func checkNextMeeting() {
    let ref = Database.database().reference().child("Teams").child(myUser.teamID).child("NextMeeting")
    ref.child(myUser.userID).observe(.value) {[weak self] (snap) in
      if let dict = snap.value as? [String:AnyObject] {
        let meeting = MeetingModel(dict)
        self?.nextMDate.text = meeting.meetingDate
        self?.nextMCity.text = meeting.meetingCity
        self?.nextMPlace.text = meeting.meetingPlace
        self?.nextID = meeting.meetingID
        if self?.myUser.userID == self?.team.adminID {
          self?.cancelBtn.isHidden = false
        }
        if meeting.seen == "false" {
          self?.nextMeetingSeen = false
          self?.checkNotifToggle()
          self?.notifBubble3.isHidden = false
          self?.nextNotifLabel.isHidden = false
        } else {
          self?.nextMeetingSeen = true
          self?.checkNotifToggle()
          self?.notifBubble3.isHidden = true
          self?.nextNotifLabel.isHidden = true
        }
        // Auto delete the meeting if time has passed - get Date from string
        let meetingFormat = meeting.formatDate
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        if let date33 = dateFormatter2.date(from: meetingFormat) {
          let now = Date()
          if date33 < now {
            ref.child((self?.myUser.userID)!).removeValue()
          }
        }
      }
    }
    
    ref.child(myUser.userID).observe(.childRemoved) { [weak self]_ in
      self?.nextMeetingSeen = true
      self?.checkNotifToggle()
      self?.notifBubble3.isHidden = true
      self?.nextNotifLabel.isHidden = true
      self?.cancelBtn.isHidden = true
      self?.nextMDate.text = "Next Meeting has not been decided yet"
      self?.nextMPlace.text = ""
      self?.nextMCity.text = ""
    }
  }
  
  @IBAction func cancelMeeting(_ sender: Any) {
    let alert = UIAlertController(title: "Are you sure?", message: "Do you want to cancel the next meeting?", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self]_ in
      self?.confirmNextCancel()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    present(alert, animated: true, completion: nil)
    
  }
  
  func confirmNextCancel() {
    let ref = Database.database().reference().child("Teams").child(myUser.teamID)
    ref.child("NextMeeting").removeValue()
  }
  
  fileprivate func getTeamData() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("teaminfo").observe(.value) {[weak self](snap) in
      if let teamDict = snap.value as? [String:AnyObject] {
        let myTeam = Team(teamDict)
        self?.team = myTeam
        self?.teamName.text = myTeam.name
        self?.teamOrg.text = myTeam.organization
        self?.teamCountry.text = myTeam.country
        self?.teamInfo.text = myTeam.info
        self?.updateNotifs()
        if myTeam.adminID == self?.myUser.userID {
          self?.editTeamBtn.isHidden = false
          if myTeam.joinStatus == "private" {
            self?.changeJoinStatus.setImage(#imageLiteral(resourceName: "button2On"), for: .normal)
          } else {
            self?.changeJoinStatus.setImage(#imageLiteral(resourceName: "button2Off"), for: .normal)
          }
        } else {
          self?.editTeamBtn.isHidden = true
        }
      }
    }
  }
  
  // MARK: Team editing :
  
  var editingTeam = false
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var countryField: UITextField!
  @IBOutlet weak var orgField: UITextField!
  @IBOutlet weak var teamInfo: UITextView!
  @IBOutlet weak var deleteButton: UIButton!
  
  @IBAction func editTeam(_ sender: Any) {
    if team.adminID == myUser.userID {
      if editingTeam == false {
        editingTeam = true
        nameField.text = team.name
        countryField.text = team.country
        orgField.text = team.organization
        teamInfo.backgroundColor = UIColor(red: 169/255, green: 183/255, blue: 211/255, alpha: 0.15)
        changePassBtn.isHidden = false
        deleteButton.isHidden = false
        teamInfo.isEditable = true
        teamName.isHidden = true
        teamOrg.isHidden = true
        teamCountry.isHidden = true
        nameField.isHidden = false
        orgField.isHidden = false
        countryField.isHidden = false
      } else {
        editingTeam = false
        team.editTeam(name:nameField.text!,country:countryField.text!,org:orgField.text!)
        teamName.text = team.name
        teamCountry.text = team.country
        teamOrg.text = team.organization
        teamInfo.backgroundColor = UIColor.clear
        changePassBtn.isHidden = true
        deleteButton.isHidden = true
        teamInfo.isEditable = false
        teamName.isHidden = false
        teamOrg.isHidden = false
        teamCountry.isHidden = false
        nameField.isHidden = true
        orgField.isHidden = true
        countryField.isHidden = true
        if viewTop.constant != 32 {
          openClosePass()
        }
        let edits = ["name":team.name,"org":team.organization,"country":team.country,"info":teamInfo.text!]
        Database.database().reference().child("Teams").child(myUser.teamID).child("teaminfo").updateChildValues(edits)
        Database.database().reference().child("teamRef").child(myUser.teamID).updateChildValues(["name":team.name])
      }
    }
  }
  
  @IBAction func changePassPressed(_ sender: Any) {
    openClosePass()
  }
  
  @IBAction func confirmPass(_ sender: Any) {
    if oldPassField.text != "" && newPassField.text != "" {
      if oldPassField.text == team.pass {
        if newPassField.text == confirmField.text {
          guard let newPass = newPassField.text else {return}
          team.changePass(pass:newPass)
          Database.database().reference().child("Teams").child(self.myUser.teamID).child("teaminfo").updateChildValues(["password":newPass])
          Database.database().reference().child("teamRef").child(self.myUser.teamID).updateChildValues(["password":newPass])
          openClosePass()
        } else {
          displayBasicAlert(title: "Passwords do not match", msg: "Make sure your new password matches the confirm password")
        }
      } else {
        displayBasicAlert(title: "Incorrect", msg: "Old password is incorrect")
      }
    }
  }
  
  @IBAction func changeStatus(_ sender: Any) {
    if team.joinStatus == "default" {
      let adjust = ["joinStatus":"private"]
      Database.database().reference().child("teamRef").child(team.id).updateChildValues(adjust)
      Database.database().reference().child("Teams").child(self.myUser.teamID).child("teaminfo").updateChildValues(adjust)
    } else {
      let adjust = ["joinStatus":"default"]
      Database.database().reference().child("teamRef").child(team.id).updateChildValues(adjust)
      Database.database().reference().child("Teams").child(self.myUser.teamID).child("teaminfo").updateChildValues(adjust)
    }
  }
  
  
  func openClosePass() {
    if viewTop.constant == 32 {
      confirmPassBtn.isHidden = false
      UIView.animate(withDuration: 0.3) {[weak self] in
        self?.viewTop.constant = 208
        self?.view.layoutIfNeeded()
      }
    } else {
      UIView.animate(withDuration: 0.3) {[weak self] in
        self?.viewTop.constant = 32
        self?.view.layoutIfNeeded()
      }
      view.endEditing(true)
      confirmPassBtn.isHidden = true
      oldPassField.text = ""
      newPassField.text = ""
      confirmField.text = ""
    }
  }
  
  @IBAction func deleteTeamPressed(_ sender: Any) {
    let alert = UIAlertController(title: "Are You Sure?", message: "Removing this team will delete all its related data", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { [weak self]_ in
      self?.deleteTriggered()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  func deleteTriggered() {
    SVProgressHUD.show()
    guard let teamid = myUser.teamID else {return}
    Database.database().reference().child("Teams").child(teamid).child("Members").observeSingleEvent(of: .value) { (snap) in
      if let users = snap.children.allObjects as? [DataSnapshot] {
        for usr in users {
          if let userDict = usr.value as? [String:AnyObject] {
            let user = User(userDict)
            Database.database().reference().child("Users").child(user.userID).updateChildValues(["team":"","joinStatus":"default"])
            Database.database().reference().child("Teams").child(teamid).child("Members").child(user.userID).removeValue()
          }
        }
      }
    }
    Database.database().reference().child("Teams").child(teamid).child("photosRef").observeSingleEvent(of: .value) { (snap) in
      if let photos = snap.children.allObjects as? [DataSnapshot] {
        for photo in photos {
          if let photosDict = photo.value as? [String:AnyObject] {
            if let photoID = photosDict["id"] as? String {
              Storage.storage().reference().child("Teams").child(teamid).child("meetingPhotos").child(photoID).delete(completion: { (error) in
                if error != nil {
                  print(error!.localizedDescription)
                }
              })
            }
          }
        }
      }
    }
    Database.database().reference().child("teamRef").child(teamid).removeValue()
    Database.database().reference().child("Teams").child(teamid).child("Meetings").removeValue()
    Database.database().reference().child("Teams").child(teamid).child("MeetingLinks").removeValue()
    Database.database().reference().child("Teams").child(teamid).child("UserTasks").removeValue()
    Database.database().reference().child("Teams").child(teamid).child("teaminfo").removeValue()
    SVProgressHUD.dismiss()
    
  }
  
  // MARK: Leaving Team
  
  @IBAction func leavePressed(_ sender: Any) {
    if myUser.userID != team.adminID {
      let alert = UIAlertController(title: "Are You Sure?", message: "Do you want to leave this team?", preferredStyle: UIAlertController.Style.alert)
      
      alert.addAction(UIAlertAction(title: "Leave", style: UIAlertAction.Style.destructive, handler: { [weak self]_ in
        self?.leaveTriggered()
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
      present(alert, animated: true, completion: nil)
    } else {
      displayBasicAlert(title: "You are the Admin", msg: "Please change the team admin first or delete the team if you are the only member")
    }
  }
  
  fileprivate func leaveTriggered() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("Members").child(myUser.userID).removeValue {[weak self] (err, ref) in
      if err == nil {
        Database.database().reference().child("Users").child((self?.myUser.userID)!).updateChildValues(["team":""])
        self?.myUser.teamID = ""
        self?.performSegue(withIdentifier: "backWelcome", sender: self?.myUser)
      }
    }
  }
  
  // MARK: Logging out & Side menu
  
  @IBAction func logOutPressed(_ sender: Any) {
    perform(#selector(handleLogOut))
  }
  
  fileprivate func checkAuth() {
    if Auth.auth().currentUser?.uid == nil {
      perform(#selector(handleLogOut), with: nil, afterDelay: 0)
    }
  }
  
  @objc func handleLogOut() {
    do {
      try Auth.auth().signOut()
      Database.database().reference().child("Users").child(myUser.userID).removeAllObservers()
      performSegue(withIdentifier: "toLogin", sender: nil)
    } catch {
      print(error.localizedDescription)
    }
    
  }
  
  @IBAction func menuBarPressed(_ sender: Any) {
    
    if menuLeading.constant != -12 {
      if editingTeam {
        editTeam(self)
      }
      UIView.animate(withDuration: 0.4) {[weak self] in
        self?.menuLeading.constant = -12
        self?.view.layoutIfNeeded()
      }
    } else {
      UIView.animate(withDuration: 0.4) {[weak self] in
        self?.menuLeading.constant = -222
        self?.view.layoutIfNeeded()
      }
      if nextMeetingLeading.constant != -200 {
        openCloseNext()
      }
    }
  }
  @IBAction func panGest(_ sender: UIPanGestureRecognizer) {
    if sender.state == .began || sender.state == .changed {
      let translation = sender.translation(in: view).x
      if translation > 20 { // Swipe right
        if editingTeam {
          editTeam(self)
        }
        UIView.animate(withDuration: 0.4) {[weak self] in
          self?.menuLeading.constant = -12
          
          self?.view.layoutIfNeeded()
        }
      } else if translation < -20 { // Swipe left
        UIView.animate(withDuration: 0.4) {[weak self] in
          self?.menuLeading.constant = -222
          self?.view.layoutIfNeeded()
        }
        if nextMeetingLeading.constant != -200 {
          openCloseNext()
        }
      }
    }
  }
  
  @IBAction func nextMPressed(_ sender: Any) {
    openCloseNext()
  }
  
  
  fileprivate func openCloseNext() {
    if nextMeetingLeading.constant == -200 {
      UIView.animate(withDuration: 0.3) {[weak self] in
        self?.nextMeetingLeading.constant = -14
        self?.view.layoutIfNeeded()
      }
      if nextMeetingSeen == false {
        let ref = Database.database().reference().child("Teams").child(myUser.teamID).child("NextMeeting")
        ref.child(myUser.userID).updateChildValues(["seen":"true"])
      }
    } else {
      UIView.animate(withDuration: 0.3) {[weak self] in
        self?.nextMeetingLeading.constant = -200
        self?.view.layoutIfNeeded()
      }
    }
  }
  
  
  
  @IBAction func addClicked(_ sender: Any) {
    if myUser.userID != team.adminID {
      performSegue(withIdentifier: "createMeeting", sender: myUser)
    } else {
      let alert = UIAlertController(title: "Add or Book?", message: "Do you want to add a meeting or book a future meeting and invite members?", preferredStyle: UIAlertController.Style.actionSheet)
      
      alert.addAction(UIAlertAction(title: "Add Meeting", style: UIAlertAction.Style.default, handler: { [weak self]_ in
        self?.addTriggered()
      }))
      alert.addAction(UIAlertAction(title: "Future Meeting", style: UIAlertAction.Style.default, handler: { [weak self]_ in
        self?.futureTriggered()
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }
  
  @IBAction func profileClicked(_ sender: Any) {
    performSegue(withIdentifier: "profile", sender: myUser)
  }
  
  fileprivate func addTriggered() {
    performSegue(withIdentifier: "createMeeting", sender: myUser)
  }
  
  fileprivate func futureTriggered() {
    performSegue(withIdentifier: "toNext", sender: self)
  }
  
  @IBAction func membersPressed(_ sender: Any) {
    performSegue(withIdentifier: "toMembers", sender: myUser)
  }
  
  fileprivate func goBackToNormal() {
    changePassBtn.isHidden = true
    deleteButton.isHidden = true
    if viewTop.constant != 32 {
      openClosePass()
    }
    menuLeading.constant = -222
    if nextMeetingLeading.constant != -200 {
      self.nextMeetingLeading.constant = -200
    }
    tableView.alpha = 1
    teamView.alpha = 1
    cellPlaceHolder.alpha = 1
    passView.alpha = 1
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    goBackToNormal()
    if let destination = segue.destination as? MeetingVC,let model = sender as? MeetingModel {
      destination.currentMeeting = model
      destination.myUser = myUser
      if editingTeam {
        editTeam(self)
      }
    }
    
    if let des = segue.destination as? ProfileVC,let user = sender as? User {
      self.checkNotifToggle()
      self.notifBubble2.isHidden = true
      self.newTaskNumber2.isHidden = true
      des.myUser = user
      des.myTeam = team
      if editingTeam {
        editTeam(self)
      }
    }
    
    if let dest = segue.destination as? MeetingAddVC,let user = sender as? User {
      dest.myUser = user
      dest.myTeam = team
      if editingTeam {
        editTeam(self)
      }
    }
    
    if let dest2 = segue.destination as? WelcomeVC,let user = sender as? User {
      dest2.myUser = user
    }
    
    if let dest5 = segue.destination as? nextMeetingVC {
      dest5.myUser = myUser
    }
    
    if let dest3 = segue.destination as? UsersTableVC, let user = sender as? User {
      dest3.myUser = user
      dest3.myTeam = team
      if editingTeam {
        editTeam(self)
      }
    }
  }
  
  
}
