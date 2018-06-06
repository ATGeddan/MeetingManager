//
//  MeetingAddVC.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/15/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MeetingAddVC: UIViewController {
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var notesText: UITextView!
    let picker = UIDatePicker()
    var myUser = User()
    var myTeam = Team()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        dateField.text = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .none)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))

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
    
    @objc func doneWithDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: picker.date)
        dateField.text = dateString
        self.view.endEditing(true)
    }
    
    @objc func donePressed() {
        SVProgressHUD.show()
        let meetingNewID = Database.database().reference().child("Teams").child(myUser.teamID).child("Meetings").childByAutoId().key
        let newDict = ["date": dateField.text!,
                       "place": placeField.text!,
                       "city": cityField.text!,
                       "notes": notesText.text!,
                       "ID":meetingNewID,
                       "teamID":myUser.teamID,
                       "adminID":myUser.userID,
                       "teamAdmin":myTeam.adminID]
        let newMeeting = MeetingModel(data: newDict as Dictionary<String, AnyObject>)
        // Upload Data to server
        let databaseRef = Database.database().reference().child("Teams").child(myUser.teamID).child("Meetings").child(newMeeting.meetingID)
        let dictionary :[String:String] = ["date":newMeeting.meetingDate,
                                           "place":newMeeting.meetingPlace,
                                           "city":newMeeting.meetingCity,
                                           "notes":newMeeting.meetingNotes,
                                           "ID":newMeeting.meetingID,
                                           "teamID":newMeeting.teamID,
                                           "adminID":myUser.userID,
                                           "teamAdmin":myTeam.adminID]
        databaseRef.setValue(dictionary) { (error, ref) in
            if error != nil {
                print(error!)
            } else {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "doneCreating", sender: newMeeting)
            }
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let destination = segue.destination as? MeetingVC {
            destination.myUser = myUser
            if let model = sender as? MeetingModel {
                destination.currentMeeting = model
            }
        }
    }
}
