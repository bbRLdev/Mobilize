//
//  UserModel.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/1/20.
//

import Foundation

class UserModel {
    
    var userID:String?
    var first:String?
    var last:String?
    //var password:String?
    var organization:String?
    var bio:String?
    var profilePicture:String?
    var eventsRSVPd:[String]?
    var eventsCreated:[String]?
    var eventsLiked:[String]?
    
    init(uid:String, first:String, last:String, organization:String, bio:String, profilePicture:String, eventsRSVPd:[String], eventsCreated:[String], eventsLiked:[String]) {
        self.userID = uid
        self.first = first
        self.last = last
        //self.password = password
        self.organization = organization
        self.bio = bio
        self.profilePicture = profilePicture
        self.eventsRSVPd = eventsRSVPd
        self.eventsCreated = eventsCreated
        self.eventsLiked = eventsLiked
    }
}
