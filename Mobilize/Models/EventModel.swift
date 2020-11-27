//
//  EventModel.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/1/20.
//

import Foundation
import MapKit

typealias Question = (question: String, answer: String)


class EventModel {
    var coordinates: CLLocationCoordinate2D?
    var date: Date?
    var organization: String?
    var description: String?
    var location: String?
    var eventName: String?
    var organizerUID: String?
    var eventID: String?
    var likeNum: Int?
    var rsvpNum: Int?
    var questions: [Question] = []
    var photoIdCollection: [String] = []
    var activismType: String?
    var eventType: String?

    enum ActivismFilterType: String, CaseIterable {
        case racialJustice = "Racial Justice",
             workersRights = "Worker's Rights",
             lgbtq = "LGBTQ+ Rights",
             votersRights = "Voter's Rights",
             environment = "Environmental",
             womensRights = "Women's Rights"
    }

    enum EventFilterType: String, CaseIterable {
        case march = "March",
             protest = "Protest",
             political = "Political",
             voting = "Voting"
    }
    
    init(){}
    
    init(name: String, desc: String, loc: String, org: String, coord: CLLocationCoordinate2D, owner: String) {
        eventName = name
        description = desc
        location = loc
        organization = org
        coordinates = coord
        organizerUID = owner
    }
    
   
    
}
