//
//  cell1.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class membersCell: UITableViewCell {
  @IBOutlet weak var cellName: UILabel!
  @IBOutlet weak var cellImage: UIImageView!
  @IBOutlet weak var cellPosition: UILabel!
  @IBOutlet weak var cellBack: UIView!
  @IBOutlet weak var adminBadge: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    cellBack.layer.cornerRadius = 10
    cellBack.addShadow(location: .bottom, color: UIColor.black, opacity: 0.8, radius: 3.0)
    cellImage.layer.cornerRadius = cellImage.frame.size.width / 2
  }
  
  func updateUI(user:User,team:Team) {
    self.cellName.text = user.userFirstName + " " + user.userLastName
    let url = URL(string: user.imageURL)
    self.cellImage.kf.setImage(with: url)
    self.cellPosition.text = user.position
    if user.userID == team.adminID {
      self.adminBadge.isHidden = false
    } else {
      self.adminBadge.isHidden = true
    }
  }
}

class commentCell: UITableViewCell {
  @IBOutlet weak var deleteTaskBtn: UIButton!
  @IBOutlet weak var deleteBtn: UIButton!
  @IBOutlet weak var commentThumb: UIImageView!
  @IBOutlet weak var commentName: UILabel!
  @IBOutlet weak var commentTime: UILabel!
  @IBOutlet weak var commentBody: UILabel!
  @IBOutlet weak var taskBody: UILabel!
  @IBOutlet weak var userName: UILabel!
  
}

class profileCell: UITableViewCell {
  @IBOutlet weak var deleteBtn: UIButton!
  @IBOutlet weak var taskLabel: UILabel!
  @IBOutlet weak var cellbackGround: UIView!
  @IBOutlet weak var dateLabel: UILabel!
}

class homeCell: UITableViewCell {
  @IBOutlet weak var cellBubble: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!
  
  func updatehomeCell(date:String,place:String,city:String) {
    cellBubble.layer.cornerRadius = 5
    dateLabel.text = date
    placeLabel.text = place + " ,"
    cityLabel.text = city
  }
}

class userCell0: UITableViewCell {
  @IBOutlet weak var userName: UILabel!
}

