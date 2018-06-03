//
//  MeetingVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/15/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD
import Firebase
import Kingfisher

class MeetingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,XMSegmentedControlDelegate {
    
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
    
    var currentMeeting = MeetingModel()
    var imagePicker : UIImagePickerController!
    let picker = UIDatePicker()
    var editingOn = false
    var segmentedControl2 = XMSegmentedControl()
    var meetingRef = DatabaseReference()
    @IBOutlet weak var deleteButton: UIButton!
    var myUser = User()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        meetingRef = Database.database().reference().child("Teams").child(currentMeeting.teamID)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        recieveMeetingInfo()
        addSegmentedController()
        getPhotos()
        setupTapAndAdmin()
        updateComments()
        createDatePicker()
        getUsers()
        updateTasks()
    }
    
    @IBAction func homeClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //______________________________________________________________________________________________________________
    // MARK: Setting up ViewDidLoad
    
    func addSegmentedController() {
        let titles = ["Photos", "Tasks", "Comments"]
        let icons = [UIImage(named: "icon1")!, UIImage(named: "icon2")!, UIImage(named: "icon3")!]
        let frame = CGRect(x: 0, y: 294, width: self.view.frame.width, height: 44)
        segmentedControl2 = XMSegmentedControl(frame: frame, segmentContent: (titles, icons), selectedItemHighlightStyle: XMSelectedItemHighlightStyle.bottomEdge)
        segmentedControl2.delegate = self
        segmentedControl2.backgroundColor = UIColor(red: 47/255, green: 69/255, blue: 121/255, alpha: 1)
        segmentedControl2.highlightColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        segmentedControl2.tint = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.7)
        segmentedControl2.highlightTint = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        segmentedControl2.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
        self.view.addSubview(segmentedControl2)
    }

    func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        if selectedSegment == 0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.photosView.alpha = 1
                self.commentsView.alpha = 0
                self.tasksView.alpha = 0
            })
        } else if selectedSegment == 1 {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.photosView.alpha = 0
                self.commentsView.alpha = 0
                self.tasksView.alpha = 1
            })
        } else if selectedSegment == 2 {
            UIView.animate(withDuration: 0.2, animations: {
                self.photosView.alpha = 0
                self.commentsView.alpha = 1
                self.tasksView.alpha = 0
            })
        }
    }
    
    func recieveMeetingInfo() {
        dateLabel.text = currentMeeting.meetingDate
        placeLabel.text = currentMeeting.meetingPlace
        cityLabel.text = currentMeeting.meetingCity
        notesText.text = currentMeeting.meetingNotes
    }
    

    
    func setupTapAndAdmin() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home-512"), style: .plain, target: self, action: #selector(homeClicked(_:)))
        if myUser.userID == currentMeeting.meetingAdmin || myUser.userID == currentMeeting.teamAdmin {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pen_paper_2-512"), style: .plain, target: self, action: #selector(ediTClicked(_:)))
            addTaskButton.isHidden = false
        }
        commentField.delegate = self
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        commentstableView.addGestureRecognizer(tapGesture1)
        // some extra view did load preps
        commentsView.alpha = 0
        tasksView.alpha = 0
        ComposeView.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
        photosView.addGestureRecognizer(imageScrollView.panGestureRecognizer)
        commentstableView.rowHeight = UITableViewAutomaticDimension
        commentstableView.estimatedRowHeight = 77
        taskTableView.rowHeight = UITableViewAutomaticDimension
        taskTableView.estimatedRowHeight = 55
        taskTableView.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
    }
    
    @objc func tableViewTapped() {
        commentField.endEditing(true)
    }

    //______________________________________________________________________________________________________________
    // MARK: Date Picker
    
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
    
    @objc func doneWithDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: picker.date)
        dateField.text = dateString
        self.view.endEditing(true)
    }
    
    //______________________________________________________________________________________________________________
    // MARK: Edit Clicked & Delete

    @IBAction func ediTClicked(_ sender: Any) {
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
    
    @IBAction func deleteAlert(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are You Sure?", message: "Do you confirm deleting this meeting with all its related data?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.destructive, handler: { action in
            self.deleteMeeting()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
     func deleteMeeting() {
        for i in 0..<allImages.count {
        Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(currentMeeting.meetingID).child(allImages[i].ID).delete { (error) in
            if error != nil {
                print(error!)
            }
        }
        }
        meetingRef.child("Meetings").child(currentMeeting.meetingID).removeValue()
        meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).removeValue()
        meetingRef.child("Comments").child(currentMeeting.meetingID).removeValue()
        meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).removeValue { (error, ref) in
            if error != nil {
                print(error!)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //______________________________________________________________________________________________________________
    // MARK: image View

    @IBOutlet weak var imageScrollView: UIScrollView!
    var allImages = [ImageModel]()
    @IBOutlet weak var addPhotoBtn: UIButton!
    
    func getPhotos() {
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
                    for x in 0..<children.count {
                        if let dict = children[x].value as? [String:AnyObject] {
                            let imageX = ImageModel(data:dict)
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
    
    func addToScroll(array:[ImageModel]) {
        for i in 0..<array.count {
            let currentImage = array[i]
            let Resource = URL(string: currentImage.url)
            let scrollWidth = self.imageScrollView.frame.size.width
            let scrollheight = self.imageScrollView.frame.size.height
            
            let newX =  scrollWidth * CGFloat(i)
            let imageview = SLImageView(frame: CGRect(x:((scrollWidth / 2) - 75) + newX , y:((scrollheight / 2) - 90) ,width:150, height:150))
            imageview.kf.setImage(with: Resource)
            imageview.contentMode = .scaleAspectFill
            imageview.layer.borderWidth = 0.5
            imageview.layer.borderColor = UIColor(red: 140/255, green: 153/255, blue: 173/255, alpha: 0.5).cgColor
            imageview.layer.cornerRadius = 10
            imageview.clipsToBounds = true
            imageview.imageID = currentImage.ID
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(saveDeleteAlert(_:)))
            imageview.addGestureRecognizer(longPress)
            self.imageScrollView.addSubview(imageview)
            self.imageScrollView.clipsToBounds = false
            self.imageScrollView.contentSize = CGSize(width:scrollWidth + newX, height:scrollheight)
        }
    }
    
    @objc func saveDeleteAlert(_ sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Save or Delete?", message: "Do you want to save or delete this image?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { action in
            let imageview = sender.view as! SLImageView
            self.saveTriggered(image: imageview.image!)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            let imageview = sender.view as! SLImageView
            let id2 = imageview.imageID
            self.deleteTriggered(id:id2!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteTriggered(id:String) {

        meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).child(id).removeValue()
        meetingRef.child("photosRef").child(id).removeValue()
        Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(id).delete { (err) in
            if err != nil {
                print(err!)
            }
        }
    }
    
    func saveTriggered(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.present(self.imagePicker, animated: true, completion: nil)
                } else {}
            })
        } else if photos == .authorized {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        SVProgressHUD.show()
        let imageID = meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).childByAutoId().key
        let storageRef = Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(imageID)
        let meetingRef2 = meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).child(imageID)
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let imageData = UIImageJPEGRepresentation(chosenImage, 0.3) else {return}
            storageRef.putData(imageData).observe(.success) { (snapshot) in
                // When the image has successfully uploaded, we get its download URL
                storageRef.downloadURL(completion: { (url, error) in
                    if let urlText = url?.absoluteString {
                        let dict = ["url" : urlText,"ID" : imageID]
                        meetingRef2.updateChildValues(dict)
                        SVProgressHUD.dismiss()
                        self.meetingRef.child("photosRef").child(imageID).setValue(["id":imageID])
                        
                    }
                })
            }
            imagePicker.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //______________________________________________________________________________________________________________
    // MARK: TableViews methods
    
    @IBOutlet weak var commentPlaceholder: UIView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:commentCell!
        if tableView.tag == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! commentCell
            if comments.count > 0 {
                let thisComment = comments[indexPath.row]
                cell.commentThumb.imageUsingCacheFromServerURL(urlString: thisComment.imageURL)
                cell.commentThumb.layer.cornerRadius = 24.5
                cell.commentThumb.layer.borderWidth = 1
                cell.commentThumb.layer.borderColor = UIColor.lightGray.cgColor
                cell.commentName.text = thisComment.name
                cell.commentTime.text = thisComment.time
                cell.commentBody.text = thisComment.body
            let myID = myUser.userID
            if myID == currentMeeting.meetingAdmin || myID == currentMeeting.teamAdmin || myID == comments[indexPath.row].userID {
                cell.deleteBtn.tag = indexPath.row
                cell.deleteBtn.isHidden = false
            }
            }
        } else if tableView.tag == 2 {
                cell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! commentCell
            if tasks.count > 0 {
                cell.taskBody.text = tasks[indexPath.row].task
                let myID = myUser.userID
                if myID == currentMeeting.meetingAdmin || myID == currentMeeting.teamAdmin {
                    cell.deleteTaskBtn.tag = indexPath.row
                    cell.deleteTaskBtn.isHidden = false
                }
            }
        } else if tableView.tag == 3 {
            cell = userstableView.dequeueReusableCell(withIdentifier: "userCell2", for: indexPath) as! commentCell
            cell.userName.text = users[indexPath.row].userFirstName + " " + users[indexPath.row].userLastName
            let view = UIImageView(image: UIImage(named: "check"))
            cell.accessoryView = view
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 3 {
            let item = users[indexPath.row].userID
            chosenUsers.append(item)
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            let view = UIImageView(image: UIImage(named: "checked"))
            cell.accessoryView = view
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.tag == 3 {
            let item = users[indexPath.row].userID
            if let index = chosenUsers.index(where: {$0 == item}) {
                chosenUsers.remove(at: index)
            }
            if let cell = tableView.cellForRow(at: indexPath) {
                let view = UIImageView(image: UIImage(named: "check"))
                cell.accessoryView = view
            }
        }
    }
    

    
    //______________________________________________________________________________________________________________
    // MARK: Comment Section
    
    @IBOutlet var commentField: UITextField!
    var comments = [Comment]()
    @IBOutlet var sendButton: UIButton!
    
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
                print(error!)
            } else {
                self.commentField.text = ""
                self.commentField.isEnabled = true
                self.sendButton.isEnabled = true
            }
        }
        }
    }
    
    func retrieveComments() {
        meetingRef.child("Comments").child(currentMeeting.meetingID).queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            self.comments = []
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for child in children {
                    if let dicto = child.value as? [String:AnyObject] {
                        let comment = Comment(data: dicto)
                        self.comments.insert(comment, at: 0)
                        self.commentstableView.reloadData()
                    }
                }
            }
        }
    }
    
    func updateComments() {
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
        let alert = UIAlertController(title: "Delete?", message: "Do you want to save or delete this comment?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            self.deleteCommentTriggered(sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteCommentTriggered(sender:UIButton) {
        meetingRef.child("Comments").child(currentMeeting.meetingID).child(comments[sender.tag].ID).removeValue { (error, ref) in
            if error == nil {
//                self.comments.remove(at: sender.tag)
                self.commentstableView.reloadData()
            }
        }
    }
    
    //______________________________________________________________________________________________________________
    // MARK: Task View
    @IBOutlet weak var taskField: UITextField!
    var addingTask = false
    var tasks = [Task]()
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var taskTableHeight: NSLayoutConstraint!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var userstableView: UITableView!
    var users = [User]()
    var chosenUsers = [String]()
    @IBOutlet var ComposeView: UIView!
    @IBOutlet weak var taskPlaceHolder: UIView!
    
    @IBAction func addClicked(_ sender: UIButton) {
        if addingTask == false { // First it unchecks the old selected users
            let selectedItems = userstableView.indexPathsForSelectedRows
            if selectedItems != nil {
            for x in selectedItems! {
                userstableView.deselectRow(at: x, animated: true)
                if let cell = userstableView.cellForRow(at: x) {
                    let view = UIImageView(image: UIImage(named: "check"))
                    cell.accessoryView = view
                }
            }
            } // Show users and text field
            addingTask = true
            UIView.animate(withDuration: 0.25) {
                self.taskTableHeight.constant = 1
                self.taskField.alpha = 1
                self.view.layoutIfNeeded()
            }
            
        } else if addingTask == true { // if a task is added
            if taskField.text != "" && chosenUsers != [] {
                addTaskButton.isEnabled = false
                UIView.animate(withDuration: 0.25) {
                    self.taskTableHeight.constant = 290
                    self.taskField.alpha = 0
                    self.view.layoutIfNeeded()
                }
                let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .none)
                let newID = meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).childByAutoId().key
                let databaseREF2 = meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).child(newID)
                let taskDict = ["task":self.taskField.text!,"done":false,"ID":newID,"date":timestamp] as [String : Any]
                databaseREF2.setValue(taskDict)
                for x in 0...chosenUsers.count - 1 {
                    let databaseREF = meetingRef.child("UserTasks").child(chosenUsers[x]).child(newID)
                    databaseREF.setValue(taskDict) { (error, ref) in
                    if error != nil {
                        print(error!)
                    }
                    self.addingTask = false
                    self.taskField.text = ""
                    self.addTaskButton.isEnabled = true
                    }
                    }
                } else { // if add was clicked to close, not add
                    addingTask = false
                    UIView.animate(withDuration: 0.25) {
                        self.taskTableHeight.constant = 290
                        self.taskField.alpha = 0
                        self.view.layoutIfNeeded()
                    }
                }
        }
    }
    
    func retrieveTasks() {
        meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).observeSingleEvent(of: .value) { (snapshot) in
            self.tasks = []
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                for child in children {
                    if let dicto2 = child.value as? [String:AnyObject] {
                        let task = Task(data: dicto2)
                        self.tasks.append(task)
                        self.taskTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func updateTasks() {
        meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).observe(.childRemoved) { (snapshot) in
            self.tasks = []
            self.retrieveTasks()
            self.taskTableView.reloadData()
        }
        meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).observe(.childAdded) { (snapshot) in
            self.tasks = []
            self.retrieveTasks()
            self.taskTableView.reloadData()
        }
    }
    
    @IBAction func deleteTaskAlert(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete?", message: "Do you want to save or delete this task?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            self.deleteTaskTriggered(sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteTaskTriggered(sender: UIButton) {
        meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).child(tasks[sender.tag].ID).removeValue { (error, ref) in
            if error == nil {
//                self.tasks.remove(at: sender.tag)
                self.taskTableView.reloadData()
            }
        }
    }
    
    func getUsers() {
        meetingRef.child("Members").observe(.childAdded) { (snapshot) in
            if let dictionary0 = snapshot.value as? [String:AnyObject] {
                let user = User(data: dictionary0)
                self.users.append(user)
                self.userstableView.reloadData()
            }
        }
    }
}
