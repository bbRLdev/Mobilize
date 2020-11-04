//
//  QAandConfirmVC.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/22/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class QAandConfirmVC: UIViewController {
    var q: Question = (question: "Is america dumb af", answer: "Yes")
    let db = Firestore.firestore()
    
    var images: [UIImage] = []
    var event: EventModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(images)
    }
    
    @IBAction func createEvent(_ sender: Any) {
        event.questions.append(q)
        if let uid = getUID() {
            event.organizerUID = uid
            event.questions.append(q)
            print(event.organizerUID!)
        }
        // self.navigationController?.popToRootViewController(animated: true)
    }
    
    func getUID() -> String? {
        let user = Auth.auth().currentUser
        if let userID: String = user?.uid {
            return userID
        }
        return nil
    }
    
    func getImages() -> [String]? {
        return []
    }
}
