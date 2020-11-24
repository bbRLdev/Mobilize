//
//  AnnotationModel.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/5/20.
//

import Foundation
import MapKit

class AnnotationModel: MKPointAnnotation{
    var eventID: String
    var date:Date?
    init(eid: String){
        eventID = eid
    }
}
