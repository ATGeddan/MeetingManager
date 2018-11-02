//
//  MeetingVC.swift
//  MeetingManager
//
//  Created by Ahmed Eltabbal on 5/15/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD
import Firebase
import Kingfisher

class MeetingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,XMSegmentedControlDelegate {
  
  @IBOutlet weak var segmentBG: UIImageView!
  @IBOutlet weak var commentstableView: UITableView!
  @IBOutlet weak var commentsView: UIView!
  @IBOutlet weak var tasksView: UIView!
  @IBOutlet weak var photosView: UIView!
  
  @IBOutlet weak var cityField: UITextField!
  @IBOutlet weak var placeField: UITextField!
  @IBOutlet weak var dateField: UITextField!
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var notesText: UITextView!
  @IBOutlet weak var deleteButton: UIButton!
  
  var currentMeeting = MeetingModel()
  lazy var imagePicker = UIImagePickerController()
  lazy var picker = UIDatePicker()
  var editingOn = false
  var meetingRef = DatabaseReference()
  
  var myUser = User()
  var updatingTasks = false
  var updatingAttachments = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    recieveMeetingInfo()
    addSegmentedController()
    setupTapAndAdmin()
    createDatePicker()
  }
  
  override internal func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    updateComments()
  }
  
  override internal func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    meetingRef.child(currentMeeting.meetingID).removeAllObservers()
    meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).removeAllObservers()
    meetingRef.child("Comments").child(currentMeeting.meetingID).removeAllObservers()
    meetingRef.child("MeetingLinks").child(currentMeeting.meetingID).removeAllObservers()
    meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).removeAllObservers()
  }
  
  @IBAction func homeClicked(_ sender: Any) {
    imageScrollView.isHidden = true
    navigationController?.popToRootViewController(animated: true)
  }
  
  //______________________________________________________________________________________________________________
  // MARK: Setting up ViewDidLoad
  
  fileprivate func addSegmentedController() {
    let titles = ["Comments", "Tasks", "Attachments"]
    let icons = [#imageLiteral(resourceName: "icon1"), #imageLiteral(resourceName: "icon2"), #imageLiteral(resourceName: "icon3")]
    let frame = CGRect(x: 0, y: 329, width: self.view.frame.width, height: 44)
    let segmentedControl2 = XMSegmentedControl(frame: frame, segmentContent: (titles, icons), selectedItemHighlightStyle: XMSelectedItemHighlightStyle.bottomEdge)
    segmentedControl2.delegate = self
    segmentedControl2.backgroundColor = UIColor.clear
    segmentedControl2.highlightColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
    segmentedControl2.tint = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.7)
    segmentedControl2.highlightTint = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    segmentedControl2.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
    self.view.addSubview(segmentedControl2)
    segmentedControl2.translatesAutoresizingMaskIntoConstraints = false
    let width = view.frame.width
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: segmentBG, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutConstraint.Attribute.topMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: segmentBG, attribute: NSLayoutConstraint.Attribute.topMargin, multiplier: 1, constant: 7).isActive = true
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width).isActive = true
    NSLayoutConstraint(item: segmentedControl2, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 44).isActive = true
  }
  
  internal func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
    if selectedSegment == 0 {
      UIView.animate(withDuration: 0.2, animations: {
        self.photosView.alpha = 0
        self.commentsView.alpha = 1
        self.tasksView.alpha = 0
      })
    } else if selectedSegment == 1 {
      if !updatingTasks {
        updatingTasks = true
        updateTasks()
        getUsers()
      }
      UIView.animate(withDuration: 0.2, animations: {
        self.photosView.alpha = 0
        self.commentsView.alpha = 0
        self.tasksView.alpha = 1
      })
    } else if selectedSegment == 2 {
      if !updatingAttachments {
        updatingAttachments = true
        getPhotos()
        updateLinks()
      }
      UIView.animate(withDuration: 0.2, animations: {
        self.photosView.alpha = 1
        self.commentsView.alpha = 0
        self.tasksView.alpha = 0
      })
    }
  }
  
  fileprivate func recieveMeetingInfo() {
    meetingRef = Database.database().reference().child("Teams").child(currentMeeting.teamID)
    dateLabel.text = currentMeeting.meetingDate
    placeLabel.text = currentMeeting.meetingPlace
    cityLabel.text = currentMeeting.meetingCity
    notesText.text = currentMeeting.meetingNotes
  }
  
  
  
  fileprivate func setupTapAndAdmin() {
    navigationItem.hidesBackButton = true
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "home-512"), style: .plain, target: self, action: #selector(homeClicked(_:)))
    if myUser.userID == currentMeeting.meetingAdmin || myUser.userID == currentMeeting.teamAdmin {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "pen_paper_2-512"), style: .plain, target: self, action: #selector(ediTClicked(_:)))
      addTaskButton.isHidden = false
    }
    commentField.delegate = self
    let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
    commentstableView.addGestureRecognizer(tapGesture1)
    // some extra view did load preps
    tasksView.alpha = 0
    photosView.alpha = 0
    attachPopUp.alpha = 0
    ComposeView.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
    photosView.addGestureRecognizer(imageScrollView.panGestureRecognizer)
    commentstableView.rowHeight = UITableView.automaticDimension
    commentstableView.estimatedRowHeight = 77
    taskTableView.rowHeight = UITableView.automaticDimension
    taskTableView.estimatedRowHeight = 55
    taskTableView.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
  }
  
  @objc fileprivate func tableViewTapped() {
    commentField.endEditing(true)
  }
  
  func createDatePicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneWithDate))
    toolbar.setItems([done], animated: true)
    toolbar.tintColor = UIColor.darkGray
    dateField.inputAccessoryView = toolbar
    dateField.inputView = picker
    picker.datePickerMode = .date
  }
  
  @objc func doneWithDate(_ field: UITextField,picker: UIDatePicker) {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    let dateString = formatter.string(from: picker.date)
    field.text = dateString
    self.view.endEditing(true)
  }
  
  //______________________________________________________________________________________________________________
  // MARK: Edit Clicked & Delete
  
  @IBAction fileprivate func ediTClicked(_ sender: Any) {
    if editingOn == false {
      editingOn = true
      dateField.text = dateLabel.text
      placeField.text = placeLabel.text
      cityField.text = cityLabel.text
      deleteButton.isHidden = false
      dateField.isHidden = false
      placeField.isHidden = false
      cityField.isHidden = false
      dateLabel.isHidden = true
      placeLabel.isHidden = true
      cityLabel.isHidden = true
      notesText.isEditable = true
    } else {
      editingOn = false
      view.endEditing(true)
      deleteButton.isHidden = true
      dateField.isHidden = true
      placeField.isHidden = true
      cityField.isHidden = true
      dateLabel.isHidden = false
      placeLabel.isHidden = false
      cityLabel.isHidden = false
      notesText.isEditable = false
      dateLabel.text = dateField.text
      placeLabel.text = placeField.text
      cityLabel.text = cityField.text
      let dictionary :[String:String] = ["date":dateField.text!,"place":placeField.text!,"city":cityField.text!,"notes":notesText.text!]
      meetingRef.child("Meetings").child(currentMeeting.meetingID).updateChildValues(dictionary)
    }
  }
  
  @IBAction fileprivate func deleteAlert(_ sender: UIButton) {
    let alert = UIAlertController(title: "Are You Sure?", message: "Do you confirm deleting this meeting with all its related data?", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.destructive, handler: { action in
      self.deleteMeeting()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  fileprivate func deleteMeeting() {
    meetingRef.child("Meetings").child(currentMeeting.meetingID).removeValue()
    for i in 0..<allImages.count {
      Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(currentMeeting.meetingID).child(allImages[i].ID).delete { (error) in
        if error != nil {
          print(error!.localizedDescription)
        }
      }
    }
    meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).removeValue()
    meetingRef.child("Comments").child(currentMeeting.meetingID).removeValue()
    meetingRef.child("MeetingLinks").child(currentMeeting.meetingID).removeValue()
    meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).removeValue { (error, ref) in
      if error != nil {
        print(error!.localizedDescription)
      }
      self.navigationController?.popToRootViewController(animated: true)
    }
  }
  
  //______________________________________________________________________________________________________________
  // MARK: image View
  
  @IBOutlet weak var imageScrollView: UIScrollView!
  var allImages = [ImageModel]()
  @IBOutlet weak var addPhotoBtn: UIButton!
  @IBOutlet weak var linksTexts: UITextView!
  
  fileprivate func getPhotos() {
    let meetingRef2 = meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID)
    meetingRef2.observe(.value) { (snap) in
      if let children = snap.children.allObjects as? [DataSnapshot] {
        if children.count > 0 {
          self.allImages.removeAll()
          self.addPhotoBtn.isHidden = true
          for view in self.imageScrollView.subviews{
            if view != self.addPhotoBtn {
              view.removeFromSuperview()
            }
          }
          for child in children {
            if let dict = child.value as? [String:AnyObject] {
              let imageX = ImageModel(dict)
              self.allImages.insert(imageX, at: 0)
              self.addToScroll(array: self.allImages)
            }
          }
        } else {
          self.addPhotoBtn.isHidden = false
          for view in self.imageScrollView.subviews{
            if view != self.addPhotoBtn {
              view.removeFromSuperview()
            }
            
          }
        }
      }
    }
  }
  
  fileprivate func addToScroll(array:[ImageModel]) {
    for i in 0..<array.count {
      let currentImage = array[i]
      let Resource = URL(string: currentImage.url)
      let scrollWidth = self.imageScrollView.frame.size.width
      let scrollheight = self.imageScrollView.frame.size.height
      
      let newX =  100 * CGFloat(i)
      let imageview = SLImageView(frame: CGRect(x:20 + newX , y:((scrollheight / 2) - 45) ,width:90, height:90))
      imageview.kf.setImage(with: Resource)
      imageview.contentMode = .scaleAspectFill
      imageview.layer.borderWidth = 0.5
      imageview.layer.borderColor = UIColor(red: 140/255, green: 153/255, blue: 173/255, alpha: 0.5).cgColor
      imageview.layer.cornerRadius = 10
      imageview.clipsToBounds = true
      imageview.imageID = currentImage.ID
      imageview._uploader = array[i].uploaderName
      let longPress = UILongPressGestureRecognizer(target: self, action: #selector(saveDeleteAlert(_:)))
      imageview.addGestureRecognizer(longPress)
      self.imageScrollView.addSubview(imageview)
      self.imageScrollView.clipsToBounds = false
      self.imageScrollView.contentSize = CGSize(width:scrollWidth + newX, height:scrollheight)
      SVProgressHUD.dismiss()
    }
  }
  
  @objc fileprivate func saveDeleteAlert(_ sender: UILongPressGestureRecognizer) {
    let alert = UIAlertController(title: "Save?", message: "Do you want to save this image?", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
      let imageview = sender.view as! SLImageView
      self.saveTriggered(image: imageview.image!)
    }))
    let imageview = sender.view as! SLImageView
    guard let id2 = imageview.imageID else {return}
    let myname = self.myUser.userFirstName + " " + self.myUser.userLastName
    if myUser.userID == currentMeeting.teamAdmin || myname == imageview.uploader || myUser.userID == currentMeeting.meetingAdmin {
      alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
        self.deleteTriggered(id:id2)
      }))
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  fileprivate func deleteTriggered(id:String) {
    
    meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).child(id).removeValue()
    meetingRef.child("photosRef").child(id).removeValue()
    Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(id).delete { (err) in
      if err != nil {
        print(err!.localizedDescription)
      }
    }
  }
  
  fileprivate func saveTriggered(image:UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
  }
  
  @IBAction func addImagePressed(_ sender: UIButton) {  // Check permission
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
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
      let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
      if let url = settingsUrl {
        DispatchQueue.main.async {
          UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil) //(url as URL)
        }
      }
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert,animated: true,completion: nil)
  }
  
  
  @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

    SVProgressHUD.show()
    let imageID = meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).childByAutoId().key
    let storageRef = Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(imageID)
    let meetingRef2 = meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).child(imageID)
    if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
      guard let imageData = chosenImage.jpegData(compressionQuality: 0.3) else {return}
      storageRef.putData(imageData).observe(.success) { (snapshot) in
        // When the image has successfully uploaded, we get its download URL
        storageRef.downloadURL(completion: { (url, error) in
          if let urlText = url?.absoluteString {
            let dict = ["url" : urlText,
                        "ID" : imageID,
                        "uploaderName":self.myUser.userFirstName + " " + self.myUser.userLastName]
            meetingRef2.updateChildValues(dict)
            self.meetingRef.child("photosRef").child(imageID).setValue(["id":imageID])
            
          }
        })
      }
      imagePicker.dismiss(animated: true, completion: nil)
      
    }
  }
  //______________________________________________________________________________________________________________
  
  @IBOutlet weak var addLinkBtn: UIButton!
  @IBOutlet weak var attachPopUp: UIView!
  @IBOutlet weak var attachTitle: UITextField!
  @IBOutlet weak var attachLink: UITextField!
  
  var links = [LinkModel]()
  
  
  @IBAction func attachLinks(_ sender: Any) {
    UIView.animate(withDuration: 0.15) {
      self.attachPopUp.alpha = 1
      self.addLinkBtn.alpha = 0
    }
  }
  
  @IBAction func attachPressed(_ sender: Any) {
    if attachTitle.text != "" && attachLink.text != "" {
      let linkRef = meetingRef.child("MeetingLinks").child(currentMeeting.meetingID).childByAutoId()
      let autoID = linkRef.key
      let linkDict = ["url":attachLink.text!,
                      "title":attachTitle.text!,
                      "uploaderID":self.myUser.userID,
                      "ID":autoID]
      linkRef.setValue(linkDict)
      UIView.animate(withDuration: 0.15) {
        self.attachPopUp.alpha = 0
        self.addLinkBtn.alpha = 1
      }
      self.attachLink.text = ""
      self.attachTitle.text = ""
      self.view.endEditing(true)
    }
  }
  
  @IBAction func cancelPressed(_ sender: Any) {
    UIView.animate(withDuration: 0.15) {
      self.attachPopUp.alpha = 0
      self.addLinkBtn.alpha = 1
    }
    attachLink.text = ""
    attachTitle.text = ""
  }
  
  fileprivate func getLinks() {
    let linkRef = meetingRef.child("MeetingLinks").child(currentMeeting.meetingID)
    linkRef.observeSingleEvent(of: .value) { (snap) in
      if let children = snap.children.allObjects as? [DataSnapshot] {
        if children.count > 0 {
          let attributedString = NSMutableAttributedString()
          self.links = []
          for i in 0..<children.count {
            if let dict = children[i].value as? [String:AnyObject] {
              let link = LinkModel(dict)
              self.links.insert(link, at: 0)
              let attributedString2 = NSMutableAttributedString(string: "\(link.title.capitalized) \n \n")
              let myRange = NSRange(location: 0 , length: link.title.count)
              attributedString2.addAttribute(.link, value: link.url, range: myRange)
              if link.title.count < 20 {
                attributedString2.addAttribute(.font, value: UIFont(name: "AvenirNext-DemiBold", size: 20)!, range: myRange)
              } else {
                attributedString2.addAttribute(.font, value: UIFont(name: "AvenirNext-DemiBold", size: 13)!, range: myRange)
              }
              attributedString2.addAttribute(kCTUnderlineStyleAttributeName as NSAttributedString.Key , value: NSUnderlineStyle.single.rawValue, range: myRange)
              attributedString.insert(attributedString2, at: 0)
              self.linksTexts.attributedText = attributedString
              let myid = self.myUser.userID
              if myid == self.currentMeeting.teamAdmin || myid == link.uploaderID || myid == self.currentMeeting.meetingAdmin {
                let y = 14.5 + (40.5 * Double(i))
                let btn = UIButton(frame: CGRect(x: Int(self.linksTexts.frame.width - 100.0), y: Int(y), width: 18, height: 18))
                btn.setImage(#imageLiteral(resourceName: "deleteCell"), for: .normal)
                btn.tag = i + 1
                btn.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                self.linksTexts.addSubview(btn)
              }
            }
          }
        }
      }
    }
    
  }
  
  fileprivate func updateLinks() {
    meetingRef.child("MeetingLinks").child(currentMeeting.meetingID).observe(.childRemoved) { (snap) in
      self.linksTexts.text = ""
      self.links = []
      self.getLinks()
      
    }
    meetingRef.child("MeetingLinks").child(currentMeeting.meetingID).observe(.childAdded) { (snap) in
      self.links = []
      self.getLinks()
    }
    
  }
  
  @objc fileprivate func buttonAction(_ sender: UIButton) {
    let alert = UIAlertController(title: "Delete?", message: "Do you want to delete this link?", preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
      self.deleteLinkTriggered(sender)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  fileprivate func deleteLinkTriggered(_ sender:UIButton) {
    let ref = meetingRef.child("MeetingLinks").child(currentMeeting.meetingID)
    for view in self.linksTexts.subviews {
      if view.tag != 0 {
        view.removeFromSuperview()
      }
    }
    ref.child(links[sender.tag - 1].ID).removeValue()
    
  }
  
  internal func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    UIApplication.shared.open(URL, options: [:])
    return false
  }
  
  //______________________________________________________________________________________________________________
  // MARK: TableViews methods
  
  
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count: Int!
    if tableView.tag == 1 {
      if comments.count == 0 {
        count = comments.count
        self.commentPlaceholder.isHidden = false
      } else {
        count = comments.count
        self.commentPlaceholder.isHidden = true
      }
    } else if tableView.tag == 2 {
      if tasks.count == 0 {
        count = tasks.count
        self.taskPlaceHolder.isHidden = false
      } else {
        count = tasks.count
        self.taskPlaceHolder.isHidden = true
      }
    } else if tableView.tag == 3 {
      count = users.count
    }
    
    return count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell:commentCell!
    if tableView.tag == 1 {
      cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? commentCell
      if comments.count > 0 {
        let thisComment = comments[indexPath.row]
        cell.configCommentCell(thisComment)
        
        let myID = myUser.userID
        if myID == currentMeeting.meetingAdmin || myID == currentMeeting.teamAdmin || myID == thisComment.userID {
          cell.deleteBtn.tag = indexPath.row
          cell.deleteBtn.isHidden = false
        }
      }
    } else if tableView.tag == 2 {
      cell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? commentCell
      if tasks.count > 0 {
        cell.taskBody.text = tasks[indexPath.row].task
        let myID = myUser.userID
        if myID == currentMeeting.meetingAdmin || myID == currentMeeting.teamAdmin {
          cell.deleteTaskBtn.tag = indexPath.row
          cell.deleteTaskBtn.isHidden = false
        }
      }
    } else if tableView.tag == 3 {
      cell = userstableView.dequeueReusableCell(withIdentifier: "userCell2", for: indexPath) as? commentCell
      cell.userName.text = users[indexPath.row].userFirstName + " " + users[indexPath.row].userLastName
      let view = UIImageView(image: #imageLiteral(resourceName: "check"))
      cell.accessoryView = view
    }
    return cell
  }
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView.tag == 3 {
      let item = users[indexPath.row].userID
      chosenUsers.append(item)
    }
    if let cell = tableView.cellForRow(at: indexPath) {
      let view = UIImageView(image: #imageLiteral(resourceName: "checked"))
      cell.accessoryView = view
    }
  }
  
  internal func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if tableView.tag == 3 {
      let item = users[indexPath.row].userID
      if let index = chosenUsers.index(where: {$0 == item}) {
        chosenUsers.remove(at: index)
      }
      if let cell = tableView.cellForRow(at: indexPath) {
        let view = UIImageView(image: #imageLiteral(resourceName: "check"))
        cell.accessoryView = view
      }
    }
  }
  
  
  
  //______________________________________________________________________________________________________________
  // MARK: Comment Section
  
  @IBOutlet weak var commentField: UITextField!
  var comments = [Comment]()
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var commentPlaceholder: UIView!
  @IBOutlet weak var ComposeView: UIView!
  
  @IBAction func sendPressed(_ sender: Any) {
    if commentField.text != "" {
      commentField.isEnabled = false
      sendButton.isEnabled = false
      let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
      let uid = myUser.userID
      let autoID = Int(NSDate.timeIntervalSinceReferenceDate*1000)
      let commentDict = ["uid":uid,
                         "time":timestamp,
                         "body":commentField.text!,
                         "ID": "\(autoID)",
        "name": myUser.userFirstName + " " + myUser.userLastName,
        "imageURL": myUser.imageURL]
      meetingRef.child("Comments").child(currentMeeting.meetingID).child("\(autoID)").setValue(commentDict) { (error, ref) in
        if error != nil {
          print(error!.localizedDescription)
        } else {
          self.commentField.text = ""
          self.commentField.isEnabled = true
          self.sendButton.isEnabled = true
        }
      }
    }
  }
  
  fileprivate func retrieveComments() {
    meetingRef.child("Comments").child(currentMeeting.meetingID).queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
      self.comments = []
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        for child in children {
          if let dicto = child.value as? [String:AnyObject] {
            let comment = Comment(dicto)
            self.comments.insert(comment, at: 0)
            self.commentstableView.reloadData()
          }
        }
      }
    }
  }
  
  fileprivate func updateComments() {
    meetingRef.child("Comments").child(currentMeeting.meetingID).queryOrderedByKey().observe(.childRemoved) { (snap) in
      self.comments = []
      self.retrieveComments()
      self.commentstableView.reloadData()
    }
    meetingRef.child("Comments").child(currentMeeting.meetingID).queryOrderedByKey().observe(.childAdded) { (snap) in
      self.comments = []
      self.retrieveComments()
      self.commentstableView.reloadData()
    }
  }
  
  @IBAction func deleteComment(_ sender: UIButton) {
    let alert = UIAlertController(title: "Delete?", message: "Do you want to save or delete this comment?", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
      self.deleteCommentTriggered(sender: sender)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  fileprivate func deleteCommentTriggered(sender:UIButton) {
    meetingRef.child("Comments").child(currentMeeting.meetingID).child(comments[sender.tag].ID).removeValue()
  }
  
  internal func textFieldDidBeginEditing(_ textField: UITextField) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  internal func textFieldDidEndEditing(_ textField: UITextField) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  //______________________________________________________________________________________________________________
  // MARK: Task View
  @IBOutlet weak var taskField: UITextField!
  var addingTask = false
  var tasks = [Task]()
  @IBOutlet weak var taskTableView: UITableView!
  @IBOutlet weak var addTaskButton: UIButton!
  @IBOutlet weak var userstableView: UITableView!
  var users = [User]()
  var chosenUsers = [String]()
  
  @IBOutlet weak var taskPlaceHolder: UIView!
  @IBOutlet weak var viewOfTaskTable: UIView!
  
  @IBAction func addClicked(_ sender: UIButton) {
    if addingTask == false { // First it unchecks the old selected users
      let selectedItems = userstableView.indexPathsForSelectedRows
      if selectedItems != nil {
        self.chosenUsers = []
        for x in selectedItems! {
          userstableView.deselectRow(at: x, animated: true)
          if let cell = userstableView.cellForRow(at: x) {
            let view = UIImageView(image: #imageLiteral(resourceName: "check"))
            cell.accessoryView = view
          }
        }
      }// Show users and text field
      addingTask = true
      UIView.animate(withDuration: 0.25) {
        self.viewOfTaskTable.alpha = 0
        self.view.layoutIfNeeded()
      }
    } else if addingTask { // if a task is added
      if taskField.text != "" && chosenUsers != [] {
        addTaskButton.isEnabled = false
        UIView.animate(withDuration: 0.25) {
          self.viewOfTaskTable.alpha = 1
          self.view.layoutIfNeeded()
        }
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .none)
        let newID = meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).childByAutoId().key
        let databaseREF2 = meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).child(newID)
        let taskDict = ["task":self.taskField.text!,"done":false,"ID":newID,"date":timestamp] as [String : Any]
        databaseREF2.setValue(taskDict)
        for x in 0...chosenUsers.count - 1 {
          meetingRef.child("NewTasks").child(chosenUsers[x]).child(newID).setValue(["task":newID])
          let databaseREF = meetingRef.child("UserTasks").child(chosenUsers[x]).child(newID)
          databaseREF.setValue(taskDict) { (error, ref) in
            if error != nil {
              print(error!.localizedDescription)
            }
            self.addingTask = false
            self.taskField.text = ""
            self.addTaskButton.isEnabled = true
          }
        }
      } else { // if add was clicked to close, not add
        addingTask = false
        UIView.animate(withDuration: 0.25) {
          self.viewOfTaskTable.alpha = 1
          self.view.layoutIfNeeded()
        }
      }
    }
  }
  
  fileprivate func retrieveTasks() {
    meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).observeSingleEvent(of: .value) { (snapshot) in
      self.tasks = []
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        for child in children {
          if let dicto2 = child.value as? [String:AnyObject] {
            let task = Task(dicto2)
            self.tasks.append(task)
            self.taskTableView.reloadData()
          }
        }
      }
    }
  }
  
  fileprivate func updateTasks() {
    meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).observe(.childRemoved) { _ in
      self.tasks = []
      self.retrieveTasks()
      self.taskTableView.reloadData()
    }
    meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).observe(.childAdded) { _ in
      self.tasks = []
      self.retrieveTasks()
      self.taskTableView.reloadData()
    }
  }
  
  @IBAction func deleteTaskAlert(_ sender: UIButton) {
    let alert = UIAlertController(title: "Delete?", message: "Do you want to save or delete this task?", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
      self.deleteTaskTriggered(sender: sender)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  fileprivate func deleteTaskTriggered(sender: UIButton) {
    meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).child(tasks[sender.tag].ID).removeValue()
  }
  
  fileprivate func getUsers() {
    meetingRef.child("Members").observeSingleEvent(of: .value) { (snapshot) in
      if let children = snapshot.children.allObjects as? [DataSnapshot] {
        for child in children {
          if let dictionary0 = child.value as? [String:AnyObject] {
            let user = User(dictionary0)
            self.users.append(user)
            self.userstableView.reloadData()
          }
        }
      }
    }
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
