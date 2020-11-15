//
//  EventDetailsViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 10/22/20.
//

import UIKit
import FirebaseFirestore
import Firebase
import CoreLocation

class EventDetailsViewController: UIViewController {
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    var eventID: String?
    var ownerUID: String = ""
    var event: EventModel!
    
    @IBOutlet weak var organizerLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak  var editButton: UIButton!
    @IBOutlet weak var stack: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editButton.isHidden = true
        loadEventInfo()
        
        // Do any additional setup after loading the view.
    }
    
    func loadEventInfo() {
        let eid = eventID
        let docRef = self.db.collection("events").document(eid!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let addr = dataDescription!["address"] as! String
                self.addressLabel.text = addr
                let uid = dataDescription!["ownerUID"] as! String
                self.ownerUID = uid
                //print(self.ownerUID)
                
                //let addr = dataDescription!["address"] as! String
                //let uid = dataDescription!["ownerUID"] as! String
                let address = dataDescription!["address"] as? String
                let coordDict = dataDescription!["coordinates"] as! NSDictionary
                let eventDesc = dataDescription!["description"] as! String
                let imgList = dataDescription!["imgURLs"] as? [String] ?? []
                let eventName = dataDescription!["name"] as! String
                let likes = dataDescription!["numLikes"] as! Int
                let RSVPs = dataDescription!["numRSVPs"] as! Int
                let orgName = dataDescription!["orgName"] as! String
                let ownerID = dataDescription!["ownerUID"] as! String
                let questions = dataDescription!["questions"] as? [NSDictionary] ?? []
                
                let latitude:Double = coordDict.value(forKey: "latitude") as! Double
                let longitude:Double = coordDict.value(forKey: "longitude") as! Double
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                
                var qList: [Question] = []
                
                for qa in questions{
                    qList.append(Question(question: qa.value(forKey: "question") as! String, answer: qa.value(forKey: "answer") as! String))
                }
                
                self.ownerUID = ownerID
                self.event = EventModel()
                self.event.location = address
                self.event.coordinates = coordinates
                self.event.description = eventDesc
                self.event.photoURLCollection = imgList
                self.event.eventName = eventName
                self.event.likeNum = likes
                self.event.rsvpNum = RSVPs
                self.event.organization = orgName
                self.event.organizerUID = ownerID
                self.event.questions = qList
                
                print(self.event.location!)
                print(self.event.coordinates!)
                print(self.event.description!)
                print(self.event.photoURLCollection)
                print(self.event.eventName!)
                print(self.event.likeNum!)
                print(self.event.rsvpNum!)
                print(self.event.organization!)
                print(self.event.organizerUID!)
                print(self.event.questions)
                
                self.checkAuth()
                
                
            }
            
        }

    }
    func checkAuth() {
        if (auth.currentUser == nil){
            print("user is nil")
        }
        else{
            print("user is not nil")
        }
        if let uid = auth.currentUser?.uid{
            print(uid)
            print(ownerUID)
            
            if uid == ownerUID {
                print("i am the creator")
                editButton.isHidden = false
                
            }
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
