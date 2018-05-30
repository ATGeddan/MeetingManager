//
//  PublicProfileVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/14/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PublicProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource,XMSegmentedControlDelegate {
    
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
    var completedTasks = [Task]()
    var segmentedControl3 = XMSegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProfile()
        retrieveTasks()
        setupSegmentedController()
        if myUser.userID == myTeam.adminID && selectedUser.userID != myTeam.adminID {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "makeAdmin"), style: .plain, target: self, action: #selector(changeAdmin))
        }
    }
    
    @objc func changeAdmin() {
        Database.database().reference().child("Teams").child(myTeam.id).child("teaminfo").updateChildValues(["adminID":selectedUser.userID,"adminName":selectedUser.userFirstName+" "+selectedUser.userLastName])
        Database.database().reference().child("Teams").child(myTeam.id).child("Meetings").observeSingleEvent(of: .value) { (snap) in
            if let meetings = snap.children.allObjects as? [DataSnapshot] {
                for x in 0..<meetings.count {
                    if let dict = meetings[x].value as? [String:AnyObject] {
                        let meeting = MeetingModel(data: dict)
                        Database.database().reference().child("Teams").child(self.myTeam.id).child("Meetings").child(meeting.meetingID).updateChildValues(["teamAdmin":self.selectedUser.userID])
                        self.myTeam.updateAdmin(id:self.selectedUser.userID)
                        
                    }
                }
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func setupSegmentedController() {
        infoView.alpha = 0
        segmentedControl3 = XMSegmentedControl(frame: CGRect(x: 0, y: 375, width: self.view.frame.width, height: 44), segmentTitle: ["Tasks", "Info"], selectedItemHighlightStyle: XMSelectedItemHighlightStyle.bottomEdge)
        segmentedControl3.delegate = self
        segmentedControl3.backgroundColor = UIColor(red: 45/255, green: 44/255, blue: 46/255, alpha: 1)
        segmentedControl3.highlightColor = UIColor(red: 187/255, green: 195/255, blue: 201/255, alpha: 1)
        segmentedControl3.tint = UIColor(red: 156/255, green: 156/255, blue: 156/255, alpha: 0.7)
        segmentedControl3.highlightTint = UIColor(red: 187/255, green: 195/255, blue: 201/255, alpha: 1)
        segmentedControl3.addShadow(location: .top, color: UIColor.black, opacity: 0.5, radius: 3.0)
        
        self.view.addSubview(segmentedControl3)
    }
    
    func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        if selectedSegment == 0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.tasksTable.alpha = 1
                self.infoView.alpha = 0
            })
        } else if selectedSegment == 1 {
            UIView.animate(withDuration: 0.2, animations: {
                self.tasksTable.alpha = 0
                self.infoView.alpha = 1
            })
        }
    }

    func setUpProfile() {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        if tasks.count > 0 {
          count = tasks.count
        } else {
            count = 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTable.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as? profileCell
        if tasks.count > 0 {
            cell?.taskLabel.text = tasks[indexPath.row].task
            cell?.cellbackGround.layer.cornerRadius = 5
            if tasks[indexPath.row].done == true {
                tasksTable.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                let view = UIImageView(image: UIImage(named: "checked"))
                cell?.accessoryView = view
            } else {
                tasksTable.deselectRow(at: indexPath, animated: false)
                let view = UIImageView(image: UIImage(named: "check"))
                cell?.accessoryView = view
            }
        }
        return cell!
    }
    
    func updateCount(){
        completedNumber.text = "\(completedTasks.count)"
    }

    func retrieveTasks() {
        Database.database().reference().child("Teams").child(selectedUser.teamID).child("UserTasks").child(selectedUser.userID).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String:AnyObject] {
                let task = Task(data: dict)
                self.tasks.append(task)
                self.tasksTable.reloadData()
                if task.done == true {
                    self.completedTasks.append(task)
                }
                self.numberOfTasks.text = "\(self.tasks.count)"
                self.updateCount()
            }
        }
    }
    
}
