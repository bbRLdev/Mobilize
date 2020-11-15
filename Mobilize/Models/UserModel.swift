//
//  UserModel.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/1/20.
//

import Foundation
import UIKit

class UserModel {
    
    var userID:String?
    var first:String?
    var last:String?
    var organization:String?
    var bio:String?
    var profilePicture:UIImage?
    var eventsRSVPd:[String]?
    var eventsCreated:[String]?
    var eventsLiked:[String]?
    var loginInfo:LoginModel?
    
    init(uid:String, first:String, last:String, organization:String, bio:String, profilePicture:UIImage, eventsRSVPd:[String], eventsCreated:[String], eventsLiked:[String], loginInfo:LoginModel) {
        self.userID = uid
        self.first = first
        self.last = last
        self.organization = organization
        self.bio = bio
        self.profilePicture = profilePicture
        self.eventsRSVPd = eventsRSVPd
        self.eventsCreated = eventsCreated
        self.eventsLiked = eventsLiked
        self.loginInfo = loginInfo
    }
    
}
