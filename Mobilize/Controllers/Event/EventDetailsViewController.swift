//
//  EventDetailsViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 10/22/20.
//

import UIKit
import Firebase

class EventDetailsViewController: UIViewController {
    let db = Firestore.firestore()
    
    var eventID: String?
    
    @IBOutlet weak var organizerLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
