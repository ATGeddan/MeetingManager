//
//  MeetingModel.swift
//  TEDxMeet
//
//  Created by Ahmed Eltabbal on 5/15/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit


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

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    public func imageUsingCacheFromServerURL(urlString: String) {
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }}