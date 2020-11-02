//
//  UserModel.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/1/20.
//

import Foundation

class UserModel {
    
    var name:String?
    var username:String?
    var password:String?
    var bio:String?
    var organization:String?
    var profilePicture:String?
    var eventsRSVPd:[String]?
    var eventsCreated:[String]?
    var eventsLiked:[String]?
    
    init(name:String, username:String, password:String, bio:String, organization:String, profilePicture:String, eventsRSVPd:[String], eventsCreated:[String], eventsLiked:[String]) {
        self.name = name
        self.username = username
        self.password = password
        self.bio = bio
        self.organization = organization
        self.profilePicture = profilePicture
        self.eventsRSVPd = eventsRSVPd
        self.eventsCreated = eventsCreated
        self.eventsLiked = eventsLiked
    }
}
