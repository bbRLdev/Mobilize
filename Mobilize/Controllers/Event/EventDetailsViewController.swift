//
//  EventDetailsViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 10/22/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventDetailsViewController: UIViewController {
    let db = Firestore.firestore()
    let auth = FirebaseAuth.Auth.auth()
    
    var eventID: String?
    var ownerUID: String = ""
    
    @IBOutlet weak var organizerLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak  var editButton: UIButton!
    @IBOutlet weak var stack: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        editButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        loadEventInfo()
        checkAuth()
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
                let uid = dataDescription!["owner"] as! String
                self.ownerUID = uid
                print(self.ownerUID)
            }
            
        }

    }
    func checkAuth() {
        let uid = auth.currentUser?.uid
        print(uid, ownerUID)
        if uid! == ownerUID {
            editButton.isHidden = false
            stack.reloadInputViews()
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
