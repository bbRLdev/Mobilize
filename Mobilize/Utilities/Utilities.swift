/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions for helping display the user interface.
*/

import UIKit
import CoreLocation
import Firebase

extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += 1
            slices.remainder.size.width -= 1
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 1
            slices.remainder.size.height -= 1
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
}

extension UIColor {
    static let appBackgroundColor = UIColor.white
}

private func deleteEventRefs(fieldName: String, eid: String){
    let db = Firestore.firestore()
    
    db.collection("users").whereField(fieldName, arrayContains: eid).getDocuments(completion: { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let userID = document.documentID
                    let userRef = db.collection("users").document(userID)
                    userRef.updateData([fieldName: FieldValue.arrayRemove([eid])])
                }
            }
    })
}

func deleteEvent(eid: String){
    
    let db = Firestore.firestore()
    
    let eventRef = db.collection("events").document(eid)
    let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com").child("events/\(eid)")
    
    eventRef.getDocument { (document, error) in
        if let document = document, document.exists {
            let dataDescription = document.data()
            
            let ownerID = dataDescription!["ownerUID"] as! String
            
            db.collection("users").document(ownerID).updateData(["createdEvents": FieldValue.arrayRemove([eid])])
            
            deleteEventRefs(fieldName: "rsvpEvents", eid: eid)
            deleteEventRefs(fieldName: "likedEvents", eid: eid)
    
            storageRef.delete(completion: { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("removing event")
                }
            })
            eventRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("removing event")
                }
            }
        }
    }

}
