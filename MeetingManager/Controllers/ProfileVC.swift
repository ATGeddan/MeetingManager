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
    
    var imagePicker : UIImagePickerController!
    
    var myTasks = [Task]()
    var completedTasks = [Task]()
    
    var editingProfile = false
    var segmentedControl3 = XMSegmentedControl()
    
    var myUser = User()
    var myTeam = Team()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoView.alpha = 0

        getUserData()
        retrieveTasks()
        setupSegmentedController()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        profImage.layer.cornerRadius = profImage.frame.size.width / 2
        profImage.layer.borderWidth = 3.5
        profImage.layer.borderColor = UIColor(red: 156/255, green: 156/255, blue: 156/255, alpha: 1).cgColor
        self.title = "MY PROFILE"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pen_paper_2-512"), style: .plain, target: self, action: #selector(editPressed(_:)))

    }
    
    func setupSegmentedController() {
        segmentedControl3 = XMSegmentedControl(frame: CGRect(x: 0, y: 375, width: self.view.frame.width, height: 44), segmentTitle: ["Tasks", "Info"], selectedItemHighlightStyle: XMSelectedItemHighlightStyle.bottomEdge)
        segmentedControl3.delegate = self
        segmentedControl3.backgroundColor = UIColor(red: 48/255, green: 68/255, blue: 107/255, alpha: 1)
        segmentedControl3.highlightColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
        segmentedControl3.tint = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.7)
        segmentedControl3.highlightTint = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        segmentedControl3.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
        
        self.view.addSubview(segmentedControl3)
    }
    
    func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        if selectedSegment == 0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.taskTableView.alpha = 1
                self.infoView.alpha = 0
            })
        } else if selectedSegment == 1 {
            UIView.animate(withDuration: 0.2, animations: {
                self.taskTableView.alpha = 0
                self.infoView.alpha = 1
                })
        }
    }
    
    func updateCount(){
        completedNumber.text = "\(completedTasks.count)"
    }


    func getUserData() {
        let image = URL(string:myUser.imageURL)
        self.contryLabel.text = self.myUser.country
        self.phoneLabel.text = self.myUser.phone
        self.emailLabel.text = self.myUser.userEmail
        self.birthLabel.text = self.myUser.birth
        self.profCity.text = self.myUser.userCity
        self.profImage.kf.setImage(with: image)
        self.profName.text = myUser.userFirstName + " " + myUser.userLastName
        self.profPosition.text = myUser.position


    }
    
    func retrieveTasks() {
        Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                let task = Task(data: dict)
                self.myTasks.append(task)
                if task.done == true {
                    self.completedTasks.append(task)
                }
                self.taskTableView.reloadData()
                self.taskNumber.text = "\(self.myTasks.count)"
                self.updateCount()
        }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        if myTasks.count > 0 {
            count = myTasks.count
        } else {
            count = 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "myprofileCell", for: indexPath) as! profileCell
        if myTasks.count > 0 {
            cell.taskLabel.text = myTasks[indexPath.row].task
            cell.dateLabel.text = myTasks[indexPath.row].date
            if myTasks[indexPath.row].done == true {
                taskTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                let view = UIImageView(image: UIImage(named: "checked"))
                cell.accessoryView = view
            } else {
                taskTableView.deselectRow(at: indexPath, animated: false)
                let view = UIImageView(image: UIImage(named: "check"))
                cell.accessoryView = view
            }
        updateCount()
        } else {
        
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if myTasks.count > 0 {
            if let cell = tableView.cellForRow(at: indexPath) {
                let view = UIImageView(image: UIImage(named: "check"))
                cell.accessoryView = view
                let currentTask = myTasks[indexPath.row]
                currentTask.clickTask()
                let adjustment = ["done" : false]
                completedTasks.remove(at: 0)
                updateCount()
                Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).child(currentTask.ID).updateChildValues(adjustment)
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if myTasks.count > 0 {
                if let cell = tableView.cellForRow(at: indexPath) {
                let view = UIImageView(image: UIImage(named: "checked"))
                cell.accessoryView = view
                let currentTask = myTasks[indexPath.row]
                currentTask.clickTask()
                let adjustment = ["done" : true]
                completedTasks.append(currentTask)
                updateCount()
                Database.database().reference().child("Teams").child(myUser.teamID).child("UserTasks").child(myUser.userID).child(currentTask.ID).updateChildValues(adjustment)
            }
        }
    }
    
    @IBAction func imagePressed(_ sender: Any) {
        
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        SVProgressHUD.show()
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let imageData = UIImageJPEGRepresentation(chosenImage, 0.1)
            Storage.storage().reference().child("profilePhoto").child(myUser.userID).putData(imageData!).observe(.success) { (snapshot) in
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
        if editingProfile == false {
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
        } else {
            editingProfile = false
            let dict = ["city" : cityEdit.text!,
                        "position" : postitionEdit.text!,
                        "phone" : phoneEdit.text!,
                        "country": countryEdit.text!,
                        "birth":birthEdit.text!,
                        "profilepicURL":myUser.imageURL]
            Database.database().reference().child("Users").child(myUser.userID).updateChildValues(dict)
            Database.database().reference().child("Teams").child(myUser.teamID).child("Members").child(myUser.userID).updateChildValues(dict)
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
