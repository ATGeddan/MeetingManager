//
//  Protocols.swift
//  MeetingManager
//
//  Created by Ahmed Eltabbal on 6/15/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import Foundation

protocol changeAdminDelegate {
  func didChangeAdmin(id:String)
}

protocol didRemoveMemberDelegate {
  func didRemoveMember()
}

protocol adminActions: changeAdminDelegate, didRemoveMemberDelegate {}
