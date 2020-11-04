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
        print("Did load \(images)")
    }
    
    @IBAction func createEvent(_ sender: Any) {
        event.questions.append(q)
        if let uid = getUID() {
            event.organizerUID = uid
            event.questions.append(q)
            let docRef = db.collection("events").addDocument(data: [
                "exists" : true
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            let eid = docRef.documentID
            event.eventID = eid
            let uploadCount = uploadImages(eventId: event.eventID!)
            print(uploadCount)
//            if(uploadCount > 0) {
//                let ret = getImageURLs(eventId: eid, uploadCount: uploadCount)
//                print(ret)
//            }
            
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
    
    func uploadImages(eventId: String) -> [String] {
//        var noError: Bool
        var ret: [String] = []
        let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        var count: Int = 0
        for image in images {
            if let imageData = image.jpegData(compressionQuality: 4.0) {
                let eventRef = storageRef.child("events").child(eventId).child("\(count)")
                eventRef.putData(imageData, metadata: metadata, completion: {
                    (storageMetadata, error) in
                    if error != nil {
                        print("error uploading image \(count)")
                        return
                    }
                    print("no errors")
                    eventRef.downloadURL(completion: { (url, error) in
                        if let err = error {
                            print(err.localizedDescription)
                        }
                        print("no errors 2")

                        guard let url = url else { return }
                        ret.append(url.absoluteString)
                        print(url.absoluteString)
                    })
                })
            }
            count += 1
        }
        return ret
    }
    
//    func getImageURLs(eventId: String, uploadCount: Int) -> [String] {
//        let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
//        var ret: [String] = []
//        for i in 0...uploadCount - 1 {
//            let eventRef = storageRef.child("events").child(eventId).child(String(i))
//            eventRef.downloadURL(completion: {
//                (url, error) in
//                if error != nil {
//                    print("Error getting image")
//                }
//                if let metaImageURL = url?.absoluteString {
//                    print(metaImageURL)
//                    ret.append(metaImageURL)
//                }
//            })
//        }
//        return ret
//    }

}
