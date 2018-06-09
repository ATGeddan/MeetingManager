//
//  UserModel.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import Foundation

class User {
    private var _userEmail:String!
    private var _userFirstName:String!
    private var _userLastName:String!
    private var _userCity:String!
    private var _userID:String!
    private var _imageURL:String!
    private var _position:String!
    private var _phone:String!
    private var _country:String!
    private var _birth:String!
    var teamID:String!
    
    var userEmail:String {
        return _userEmail
    }
    var userFirstName:String {
        return _userFirstName
    }
    var userLastName:String {
        return _userLastName
    }
    var userCity:String {
        return _userCity
    }
    var userID:String {
        return _userID
    }
    var imageURL:String {
        return _imageURL
    }
    var position:String {
        return _position
    }
    var phone:String {
        return _phone
    }
    var country:String {
        return _country
    }
    var birth:String {
        return _birth
    }

    
    init() {
    }
    
    convenience init(data:Dictionary<String,AnyObject>) {
        self.init()
        if let email = data["email"] as? String {
            _userEmail = email
        }
        if let firstName = data["firstname"] as? String {
            _userFirstName = firstName
        }
        if let lastName = data["lastname"] as? String {
            _userLastName = lastName
        }
        if let city = data["city"] as? String {
            _userCity = city
        }
        if let ID = data["uid"] as? String {
            _userID = ID
        }
        if let URL = data["profilepicURL"] as? String {
            _imageURL = URL
        }
        if let pos = data["position"] as? String {
            _position = pos
        }
        if let pho = data["phone"] as? String {
            _phone = pho
        }
        if let cntry = data["country"] as? String {
            _country = cntry
        }
        if let brth = data["birth"] as? String {
            _birth = brth
        }
        if let team = data["team"] as? String {
            teamID = team
        }
    }
    
    func updateUser(data:Dictionary<String,AnyObject>) {
        
        if let email = data["email"] as? String {
            _userEmail = email
        }
        if let firstName = data["firstname"] as? String {
            _userFirstName = firstName
        }
        if let lastName = data["lastname"] as? String {
            _userLastName = lastName
        }
        if let city = data["city"] as? String {
            _userCity = city
        }
        if let ID = data["uid"] as? String {
            _userID = ID
        }
        if let URL = data["profilepicURL"] as? String {
            _imageURL = URL
        }
        if let pos = data["position"] as? String {
            _position = pos
        }
        if let pho = data["phone"] as? String {
            _phone = pho
        }
        if let cntry = data["country"] as? String {
            _country = cntry
        }
        if let brth = data["birth"] as? String {
            _birth = brth
        }
        if let team = data["team"] as? String {
            teamID = team
        }
    }
    
    func changePhoto(url:String) {
        _imageURL = url
    }
}
// ------------------------------------------

class Team {
    private var _name:String!
    private var _id:String!
    private var _country:String!
    private var _organization:String!
    private var _info:String!
    private var _pass:String!
    private var _adminID:String!
    private var _adminName:String!
    
    var name:String {
        return _name
    }
    var id:String {
        return _id
    }
    var country:String {
        return _country
    }
    var organization:String {
        return _organization
    }
    var info:String {
        return _info
    }
    var pass:String {
        return _pass
    }
    var adminID:String {
        return _adminID
    }
    var adminName:String {
        return _adminName
    }
    
    init() {}
    
    convenience init(data:Dictionary<String,AnyObject>) {
        self.init()
        
        if let name = data["name"] as? String {
            _name = name
        }
        if let id = data["id"] as? String {
            _id = id
        }
        if let country = data["country"] as? String {
            _country = country
        }
        if let organization = data["org"] as? String {
            _organization = organization
        }
        if let info = data["info"] as? String {
            _info = info
        }
        if let pass = data["password"] as? String {
            _pass = pass
        }
        if let adminID = data["adminID"] as? String {
            _adminID = adminID
        }
        if let adminName = data["adminName"] as? String {
            _adminName = adminName
        }
    }
    
    func editTeam(name:String,country:String,org:String) {
        _name = name
        _country = country
        _organization = org
    }
    
    func getOnlyName(name:String) {
        _name = name
    }
    
    func updateAdmin(id:String) {
        _adminID = id
    }
    
    func changePass(pass:String) {
        _pass = pass
    }
}

// ------------------------------------------

class MeetingModel {
    private var _meetingDate:String!
    private var _meetingPlace:String!
    private var _meetingCity:String!
    private var _meetingNotes:String!
    private var _meetingID:String!
    private var _teamID:String!
    private var _meetingAdmin:String!
    private var _teamAdmin:String!
    private var _formatDate:String!
    private var _seen:String!
    
    var meetingDate:String {
        return _meetingDate
    }
    var meetingPlace:String {
        return _meetingPlace
    }
    var meetingCity:String {
        return _meetingCity
    }
    var meetingNotes:String {
        return _meetingNotes
    }
    var meetingID:String {
        return _meetingID
    }
    var teamID:String {
        return _teamID
    }
    var meetingAdmin:String {
        return _meetingAdmin
    }
    var teamAdmin:String {
        return _teamAdmin
    }
    var formatDate:String {
        return _formatDate
    }
    var seen:String {
        return _seen
    }
    
    init() {
    }
    
    convenience init(data:Dictionary<String,AnyObject>) {
        self.init()
        if let date = data["date"] as? String {
            _meetingDate = date
        }
        if let place = data["place"] as? String {
            _meetingPlace = place
        }
        if let city = data["city"] as? String {
            _meetingCity = city
        }
        if let id = data["ID"] as? String {
            _meetingID = id
        }
        if let notes = data["notes"] as? String {
            _meetingNotes = notes
        }
        if let teamID = data["teamID"] as? String {
            _teamID = teamID
        }
        if let meetingAdmin = data["adminID"] as? String {
            _meetingAdmin = meetingAdmin
        }
        if let teamAdmin = data["teamAdmin"] as? String {
            _teamAdmin = teamAdmin
        }
        if let formatDate = data["formatDate"] as? String {
            _formatDate = formatDate
        }
        if let seen = data["seen"] as? String {
            _seen = seen
        }
    }
    
}
// ------------------------------------------
// Meeting Comment
class Comment {
    private var _imageURL:String!
    private var _name:String!
    private var _time:String!
    private var _body:String!
    private var _ID:String!
    private var _userID:String!
    
    var imageURL:String {
        return _imageURL
    }
    var name:String {
        return _name
    }
    var time:String {
        return _time
    }
    var body:String {
        return _body
    }
    var ID:String {
        return _ID
    }
    var userID:String {
        return _userID
    }
    
    init(data:Dictionary<String,AnyObject>) {
        if let imageURL = data["imageURL"] as? String {
            _imageURL = imageURL
        }
        if let name = data["name"] as? String {
            _name = name
        }
        if let time = data["time"] as? String {
            _time = time
        }
        if let body = data["body"] as? String {
            _body = body
        }
        if let ID = data["ID"] as? String {
            _ID = ID
        }
        if let userID = data["uid"] as? String {
            _userID = userID
        }
    }
}
// ------------------------------------------
// Meeting & User Task
class Task {
    private var _task:String!
    private var _done = false
    private var _ID:String!
    private var _date:String!

    var task:String {
        return _task
    }
    var done:Bool {
        return _done
    }
    var ID:String{
        return _ID
    }
    var date:String{
        return _date
    }
    
    init(data:Dictionary<String,AnyObject>) {
        if let task2 = data["task"] as? String {
            _task = task2
        }
        if let done2 = data["done"] as? Bool {
            _done = done2
        }
        if let ID2 = data["ID"] as? String {
            _ID = ID2
        }
        if let date = data["date"] as? String {
            _date = date
        }
        
    }
    
    func clickTask() {
        _done = !_done
    }

}

// ------------------------------------------
// Meeting Image

class ImageModel {
    private var _url:String!
    private var _ID:String!
    private var _uploaderName:String!
    
    var url:String {
        return _url
    }
    
    var ID:String {
        return _ID
    }
    var uploaderName:String {
        return _uploaderName
    }
    
    init(data:Dictionary<String,AnyObject>) {
        if let url2 = data["url"] as? String {
            _url = url2
        }
        if let ID2 = data["ID"] as? String {
            _ID = ID2
        }
        if let uploaderName2 = data["uploaderName"] as? String {
            _uploaderName = uploaderName2
        }
    }
}

// ------------------------------------------
// Meeting Link

class LinkModel {
    private var _url:String!
    private var _title:String!
    private var _uploaderID:String!
    private var _ID:String!
    
    var url:String {
        return _url
    }
    
    var title:String {
        return _title
    }
    var uploaderID:String {
        return _uploaderID
    }
    var ID:String {
        return _ID
    }
    
    init(data:Dictionary<String,AnyObject>) {
        if let url = data["url"] as? String {
            _url = url
        }
        if let title = data["title"] as? String {
            _title = title
        }
        if let uploaderID = data["uploaderID"] as? String {
            _uploaderID = uploaderID
        }
        if let ID = data["ID"] as? String {
            _ID = ID
        }
    }
}

