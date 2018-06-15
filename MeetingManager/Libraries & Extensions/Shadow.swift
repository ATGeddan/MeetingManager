//
//  MeetingModel.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/15/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit

// Adding custom shadow

enum VerticalLocation: String {
  case bottom
  case top
  case right
  case left
}

extension UIView {
  func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
    switch location {
    case .bottom:
      addShadow(offset: CGSize(width: 0, height: 3), color: color, opacity: opacity, radius: radius)
    case .top:
      addShadow(offset: CGSize(width: 0, height: -3), color: color, opacity: opacity, radius: radius)
    case .right:
      addShadow(offset: CGSize(width: 3, height: 0), color: color, opacity: opacity, radius: radius)
    case .left:
      addShadow(offset: CGSize(width: -3, height: 0), color: color, opacity: opacity, radius: radius)
    }
    
  }
  
  func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
    self.layer.masksToBounds = false
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOffset = offset
    self.layer.shadowOpacity = opacity
    self.layer.shadowRadius = radius
  }
}
// _____________
extension UIImageView {
  override open func awakeFromNib() {
    super.awakeFromNib()
    self.tintColorDidChange()
  }
}

