//
//  cell1.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/13/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class cell1: UITableViewCell {
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellPosition: UILabel!
    @IBOutlet weak var cellBack: UIView!
    
    override func awakeFromNib() {
        cellBack.layer.cornerRadius = 10
        cellBack.addShadow(location: .bottom, color: UIColor.black, opacity: 0.8, radius: 3.0)
    }
}

class commentCell: UITableViewCell {
    @IBOutlet weak var commentThumb: UIImageView!
    @IBOutlet weak var commentName: UILabel!
    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var commentBody: UILabel!
    @IBOutlet weak var taskBody: UILabel!
    @IBOutlet weak var userName: UILabel!
    
}

class profileCell: UITableViewCell {
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var cellbackGround: UIView!
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

