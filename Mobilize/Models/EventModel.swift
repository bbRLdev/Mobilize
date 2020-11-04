//
//  EventModel.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/1/20.
//

import Foundation


typealias Question = (question: String, answer: String)

class EventModel {
    var organization: String
    var description: String
    var location: String
    var eventName: String
    var organizerUID: String!
    var eventID: String!
    var likeNum = 0
    var rsvpNum = 0
    var questions: [Question] = []
    var photoURLCollection: [String] = []
    
    init(name: String, desc: String, loc: String, org: String) {
        eventName = name
        description = desc
        location = loc
        organization = org
    }
    
}
