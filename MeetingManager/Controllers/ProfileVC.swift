//
//  ProfileVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import Photos
import SVProgressHUD
import Kingfisher

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,XMSegmentedControlDelegate {
  
  @IBOutlet weak var segmentBG: UIImageView!
  @IBOutlet weak var taskPlaceHolder: UIView!
  @IBOutlet weak var tasksView: UIView!
  @IBOutlet weak var birthEdit: UITextField!
  @IBOutlet weak var photoButton: UIButton!
  @IBOutlet weak var birthLabel: UILabel!
  @IBOutlet weak var phoneEdit: UITextField!
  @IBOutlet weak var countryEdit: UITextField!
  @IBOutlet weak var completedNumber: UILabel!
  @IBOutlet weak var taskNumber: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var contryLabel: UILabel!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var postitionEdit: UITextField!
  @IBOutlet weak var profPosition: UILabel!
  @IBOutlet weak var cityEdit: UITextField!
  @IBOutlet weak var profImage: UIImageView!
  @IBOutlet weak var profName: UILabel!
  @IBOutlet weak var profCity: UILabel!
  
  @IBOutlet weak var taskTableView: UITableView!
  
  lazy var imagePicker = UIImagePickerController()
  
  var myTasks = [Task]()
  var completedTasks = 0
  
  var editingProfile = false
  var segmentedControl2 = XMSegmentedControl()
  
  var myUser = User()
  var myTeam = Team()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.infoView.alpha = 0
    getUserData()
    setupSegmentedController()
    NavBarSetup()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    Database.database().reference().child("Teams").child(myUser.teamID).child("NewTasks").child(myUser.userID).removeValue()
    updateTasks()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).removeAllObservers()
  }
  
  fileprivate func NavBarSetup() {
    self.title = "MY PROFILE"
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pen_paper_2-512"), style: .plain, target: self, action: #selector(editPressed(_:)))
  }
  
  
  fileprivate func setupSegmentedController() {
    segmentedControl2 = XMSegmentedControl(frame: CGRect(x: 0, y: 375, width: self.view.frame.width, height: 44), segmentTitle: ["Tasks", "Info"], selectedItemHighlightStyle: XMSelectedItemHighlightStyle.bottomEdge)
    segmentedControl2.delegate = self
    segmentedControl2.backgroundColor = UIColor.clear
    segmentedControl2.highlightColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
    segmentedControl2.tint = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.7)
    segmentedControl2.highlightTint = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    segmentedControl2.addShadow(location: .top, color: UIColor.darkGray, opacity: 0.5, radius: 3.0)
    
    self.view.addSubview(segmentedControl2)
    segmentedControl2.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: segmentBG, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: segmentBG, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 7).isActive = true
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 375).isActive = true
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44).isActive = true
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
  
  fileprivate func updateCount(){
    completedNumber.text = "\(completedTasks)"
  }
  
  
  fileprivate func getUserData() {
    let image = URL(string:myUser.imageURL)
    contryLabel.text = myUser.country
    phoneLabel.text = myUser.phone
    emailLabel.text = myUser.userEmail
    birthLabel.text = myUser.birth
    profCity.text = myUser.userCity
    profImage.kf.setImage(with: image)
    profName.text = myUser.userFirstName + " " + myUser.userLastName
    profPosition.text = myUser.position
    profImage.layer.cornerRadius = profImage.frame.size.width / 2
    profImage.layer.borderWidth = 3.5
    profImage.layer.borderColor = UIColor(red: 156/255, green: 156/255, blue: 156/255, alpha: 1).cgColor
    
    
  }
  
  
  fileprivate func retrieveTasks() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).observeSingleEvent(of: .value) { (snapshot) in
      self.myTasks = []
      self.completedTasks = 0
      Database.database().reference().child("Teams").child(self.myUser.teamID).child("NewTasks").child(self.myUser.userID).removeValue()
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        for child in children {
          if let dict = child.value as? [String:AnyObject] {
            let task = Task(data: dict)
            self.myTasks.append(task)
            self.taskTableView.reloadData()
            if task.done == true {
              self.completedTasks += 1
            }
            self.taskNumber.text = "\(self.myTasks.count)"
            self.updateCount()
          }
        }
      }
    }
  }
  
  fileprivate func updateTasks() {
    Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).observe(.childAdded) { (snap) in
      self.myTasks = []
      self.completedTasks = 0
      self.retrieveTasks()
      self.taskTableView.reloadData()
    }
    Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).observe(.childRemoved) { (snap) in
      self.myTasks = []
      self.completedTasks = 0
      self.retrieveTasks()
      self.taskTableView.reloadData()
      self.taskNumber.text = "\(self.myTasks.count)"
      self.updateCount()
    }
  }
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count:Int!
    if myTasks.count > 0 {
      count = myTasks.count
      self.taskPlaceHolder.isHidden = true
    } else {
      count = 0
      self.taskPlaceHolder.isHidden = false
    }
    return count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = taskTableView.dequeueReusableCell(withIdentifier: "myprofileCell", for: indexPath) as! profileCell
    if myTasks.count > 0 {
      let theTask = myTasks[indexPath.row]
      cell.configProfileCell(theTask)
      cell.checkTaskStatus(task: theTask, table: tableView, indexPath: indexPath)
      updateCount()
    }
    return cell
  }
  
  internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65.0
  }
  
  internal func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if myTasks.count > 0 {
      if let cell = tableView.cellForRow(at: indexPath) {
        let view = UIImageView(image: UIImage(named: "check"))
        cell.accessoryView = view
        let currentTask = myTasks[indexPath.row]
        currentTask.clickTask()
        let adjustment = ["done" : false]
        completedTasks -= 1
        updateCount()
        Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).child(currentTask.ID).updateChildValues(adjustment)
      }
    }
  }
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if myTasks.count > 0 {
      if let cell = tableView.cellForRow(at: indexPath) {
        let view = UIImageView(image: UIImage(named: "checked"))
        cell.accessoryView = view
        let currentTask = myTasks[indexPath.row]
        currentTask.clickTask()
        let adjustment = ["done" : true]
        completedTasks += 1
        updateCount()
        Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).child(currentTask.ID).updateChildValues(adjustment)
      }
    }
  }
  
  @IBAction func imagePressed(_ sender: Any) {
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      self.present(self.imagePicker,animated: true,completion: nil)
      break
    case .denied, .restricted :
      self.handleAccessDeny()
      break
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization() { status in
        switch status {
        case .authorized:
          self.present(self.imagePicker,animated: true,completion: nil)
          break
        case .denied, .restricted:
          self.handleAccessDeny()
          break
        case .notDetermined:
          break
        }
      }
    }
  }
  
  fileprivate func handleAccessDeny() {
    let alert = UIAlertController(title: "Access denied", message: "You need to allow MeetingManager access to your gallery to upload an image.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
      let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
      if let url = settingsUrl {
        DispatchQueue.main.async {
          UIApplication.shared.open(url as URL, options: [:], completionHandler: nil) //(url as URL)
        }
      }
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert,animated: true,completion: nil)
  }
  
  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    SVProgressHUD.show()
    if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
      guard let imageData = UIImageJPEGRepresentation(chosenImage, 0.1) else {return}
      Storage.storage().reference().child("profilePhoto").child(myUser.userID).putData(imageData).observe(.success) { (snapshot) in
        // When the image has successfully uploaded, we get it's download URL
        Storage.storage().reference().child("profilePhoto").child(self.myUser.userID).downloadURL(completion: { (url, error) in
          if let urlText = url?.absoluteString {
            let dict = ["profilepicURL" : urlText]
            Database.database().reference().child("Users").child(self.myUser.userID).updateChildValues(dict)
            self.profImage.image = chosenImage
            self.myUser.changePhoto(url: urlText)
            SVProgressHUD.dismiss()
            
          }
        })
      }
      imagePicker.dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func editPressed(_ sender: Any) {
    if editingProfile == false { // Start Editing
      editingProfile = true
      cityEdit.text = profCity.text
      postitionEdit.text = profPosition.text
      phoneEdit.text = phoneLabel.text
      countryEdit.text = contryLabel.text
      birthEdit.text = birthLabel.text
      birthLabel.isHidden = true
      profCity.isHidden = true
      profPosition.isHidden = true
      phoneLabel.isHidden = true
      contryLabel.isHidden = true
      photoButton.isHidden = false
      profImage.alpha = 0.6
      phoneEdit.isHidden = false
      birthEdit.isHidden = false
      countryEdit.isHidden = false
      postitionEdit.isHidden = false
      cityEdit.isHidden = false
    } else { // Done Editing
      editingProfile = false
      let newData = ["city" : cityEdit.text!,
                     "position" : postitionEdit.text!,
                     "phone" : phoneEdit.text!,
                     "country": countryEdit.text!,
                     "birth":birthEdit.text!,
                     "profilepicURL":myUser.imageURL]
      Database.database().reference().child("Users").child(myUser.userID).updateChildValues(newData)
      Database.database().reference().child("Teams").child(myUser.teamID).child("Members").child(myUser.userID).updateChildValues(newData)
      profCity.text = cityEdit.text
      profPosition.text = postitionEdit.text
      phoneLabel.text = phoneEdit.text
      contryLabel.text = countryEdit.text
      birthLabel.text = birthEdit.text
      birthLabel.isHidden = false
      profCity.isHidden = false
      profPosition.isHidden = false
      phoneLabel.isHidden = false
      contryLabel.isHidden = false
      photoButton.isHidden = true
      profImage.alpha = 1
      birthEdit.isHidden = true
      phoneEdit.isHidden = true
      countryEdit.isHidden = true
      postitionEdit.isHidden = true
      cityEdit.isHidden = true
    }
  }
  
  
  
}
