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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        meetingRef = Database.database().reference().child("Teams").child(currentMeeting.teamID)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        commentField.delegate = self
        photosView.addGestureRecognizer(imageScrollView.panGestureRecognizer)
        recieveMeetingInfo()
        addSegmentedController()
        getPhotos()
        setupImageTapAndAdmin()
        retrieveComments()
        createDatePicker()
        getUsers()
        retrieveTasks()
    }
    
    @IBAction func homeClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Setting up ViewDidLoad
    
    func addSegmentedController() {
        let titles = ["Photos", "Tasks", "Comments"]
        let icons = [UIImage(named: "icon1")!, UIImage(named: "icon2")!, UIImage(named: "icon3")!]
        let frame = CGRect(x: 0, y: 294, width: self.view.frame.width, height: 44)
        segmentedControl2 = XMSegmentedControl(frame: frame, segmentContent: (titles, icons), selectedItemHighlightStyle: XMSelectedItemHighlightStyle.bottomEdge)
        segmentedControl2.delegate = self
        segmentedControl2.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 47/255, alpha: 1)
        segmentedControl2.highlightColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
        segmentedControl2.tint = UIColor.lightGray
        segmentedControl2.highlightTint = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)
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
    

    
    func setupImageTapAndAdmin() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home-512"), style: .plain, target: self, action: #selector(homeClicked(_:)))
        if Auth.auth().currentUser?.uid == currentMeeting.meetingAdmin || Auth.auth().currentUser?.uid == currentMeeting.teamAdmin {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pen_paper_2-512"), style: .plain, target: self, action: #selector(ediTClicked(_:)))
            addTaskButton.isHidden = false
        }
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        commentstableView.addGestureRecognizer(tapGesture1)
        // some extra view did load preps
        commentsView.alpha = 0
        tasksView.alpha = 0
        ComposeView.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
        
    }
    
    @objc func tableViewTapped() {
        commentField.endEditing(true)
    }

    
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
        Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(currentMeeting.meetingID).delete { (err) in
            if err != nil {
                print(err!)
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
        Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(currentMeeting.meetingID).child(id).delete { (err) in
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
    

    @IBAction func imageClicked(_ sender: UIButton) {
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
        let imageID = Int(NSDate.timeIntervalSinceReferenceDate*1000)
        let storageRef = Storage.storage().reference().child("Teams").child(currentMeeting.teamID).child("meetingPhotos").child(currentMeeting.meetingID).child("d\(imageID)")
        let meetingRef2 = meetingRef.child("MeetingPhotos").child(currentMeeting.meetingID).child("d\(imageID)")
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let imageData = UIImageJPEGRepresentation(chosenImage, 0.4) else {return}
            storageRef.putData(imageData).observe(.success) { (snapshot) in
                // When the image has successfully uploaded, we get its download URL
                storageRef.downloadURL(completion: { (url, error) in
                    if let urlText = url?.absoluteString {
                        let dict = ["url" : urlText,"ID" : "d\(imageID)"]
                        meetingRef2.updateChildValues(dict)
                        SVProgressHUD.dismiss()
                        
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
    
    // MARK: TableViews methods
    @IBOutlet weak var commentPlaceholder: UIView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int!
        if tableView.tag == 1 {
            if comments.count == 0 {
                count = 0
                self.commentPlaceholder.isHidden = false
            } else {
                count = comments.count
                self.commentPlaceholder.isHidden = true
            }
        } else if tableView.tag == 2 {
            if tasks.count == 0 {
                count = 1
            } else {
                count = tasks.count
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
                cell.commentThumb.imageUsingCacheFromServerURL(urlString: comments[indexPath.row].imageURL)
                cell.commentThumb.layer.cornerRadius = 30
                cell.commentThumb.layer.borderWidth = 1
                cell.commentThumb.layer.borderColor = UIColor.lightGray.cgColor
                cell.commentName.text = comments[indexPath.row].name
                cell.commentTime.text = comments[indexPath.row].time
                cell.commentBody.text = comments[indexPath.row].body
        } else if tableView.tag == 2 {
            if tasks.count == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! commentCell
            } else {
                cell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! commentCell
                cell.taskBody.text = tasks[indexPath.row].task
            }
        } else if tableView.tag == 3 {
            cell = userstableView.dequeueReusableCell(withIdentifier: "userCell2", for: indexPath) as! commentCell
            cell.userName.text = users[indexPath.row].userFirstName + " " + users[indexPath.row].userLastName
            let view = UIImageView(image: UIImage(named: "check"))
            cell.accessoryView = view
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var high:CGFloat!
        if tableView.tag == 1 {
            high = 77.0
        } else if tableView.tag == 2 {
            high = 49.0
        } else if tableView.tag == 3 {
            high = 30.0
        }
        return high
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
    
    
    // MARK: Comment Section
    @IBOutlet var commentField: UITextField!
    var comments = [Comment]()
    @IBOutlet var sendButton: UIButton!
    
    @IBAction func sendPressed(_ sender: Any) {
        if commentField.text != "" {
            commentField.isEnabled = false
            sendButton.isEnabled = false
            let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
            let timeID = Int(NSDate.timeIntervalSinceReferenceDate*1000)
            let uid = Auth.auth().currentUser?.uid
            let commentDict = ["uid":uid,"time":timestamp,"body":commentField.text!, "ID": "c\(timeID)"]
            meetingRef.child("Comments").child(currentMeeting.meetingID).child("c\(timeID)").setValue(commentDict) { (error, ref) in
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
        meetingRef.child("Comments").child(currentMeeting.meetingID).observe(.childAdded) { (snapshot) in
            if let dicto = snapshot.value as? [String:AnyObject] {
                if let time = dicto["time"] as? String,let body = dicto["body"] as? String,let UserID = dicto["uid"] as? String,let comID = dicto["ID"] as? String {
                    Database.database().reference().child("Users").child(UserID).observeSingleEvent(of: .value, with: { (snap) in
                        if let dictionary2 = snap.value as? [String:AnyObject] {
                            let commenter = User(data: dictionary2)
                            let name = commenter.userFirstName + " " + commenter.userLastName
                            let comment = Comment(name:name,time:time,body:body,url:commenter.imageURL, id: comID)
                            self.comments.insert(comment, at: 0)
                            self.commentstableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    
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
    
    @IBAction func addClicked(_ sender: UIButton) {
        if addingTask == false {
            let selectedItems = userstableView.indexPathsForSelectedRows
            if selectedItems != nil {
            for x in selectedItems! {
                userstableView.deselectRow(at: x, animated: true)
                if let cell = userstableView.cellForRow(at: x) {
                    let view = UIImageView(image: UIImage(named: "check"))
                    cell.accessoryView = view
                }
            }
            }
            addingTask = true
            UIView.animate(withDuration: 0.25) {
                self.taskTableHeight.constant = 1
                self.taskField.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else if addingTask == true {
            if taskField.text != "" && chosenUsers != [] {
                addTaskButton.isEnabled = false
                UIView.animate(withDuration: 0.25) {
                    self.taskTableHeight.constant = 290
                    self.taskField.alpha = 0
                    self.view.layoutIfNeeded()
                }
                let timeStamp = Int(NSDate.timeIntervalSinceReferenceDate*1000)
                let databaseREF2 = meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).child("e\(timeStamp)")
                let taskDict = ["task":self.taskField.text!,"done":false,"ID":"e\(timeStamp)"] as [String : Any]
                databaseREF2.setValue(taskDict)
                for x in 0...chosenUsers.count - 1 {
                    let databaseREF = meetingRef.child("UserTasks").child(chosenUsers[x]).child("e\(timeStamp)")
                    databaseREF.setValue(taskDict) { (error, ref) in
                    if error != nil {
                        print(error!)
                    }
                    self.addingTask = false
                    self.taskField.text = ""
                    self.addTaskButton.isEnabled = true
                    }
                    }
                } else {
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
        meetingRef.child("MeetingTasks").child(currentMeeting.meetingID).observe(.childAdded) { (snapshot) in
            
            if let dicto2 = snapshot.value as? [String:AnyObject] {
                let task = Task(data: dicto2)
                self.tasks.append(task)
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
