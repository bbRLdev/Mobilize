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
    //var q: Question = (question: "Is america dumb af", answer: "Yes")
    let db = Firestore.firestore()
    let cellTag = "tag"
    
    var images: [UIImage] = []
    var event: EventModel!
    var eventSoFar: [String : Any] = [:]
    var imgURLs: [String] = []
    var questions: [Question] = []
    
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var qaTableView: UITableView!
    
    
    var imgLoadingFlag = false {
        willSet {
            if newValue == false {
                print(imgURLs)
                eventSoFar["imgURLs"] = imgURLs
                //questions.append(q)
                collectionLoadingFlag = true
                uploadCollection()
            }
        }
        
    }
    
    
    var collectionLoadingFlag = false {
        willSet {
            if newValue == false {
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
                //createButton.isUserInteractionEnabled = true
                //createButton.setTitle("Create Event", for: .normal)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Did load \(images)")
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "Some default text"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField!.text)")
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func createEvent(_ sender: Any) {
        createButton.setTitle("Uploading...", for: .normal)
        createButton.isUserInteractionEnabled = false
        
        if let uid = getUID() {
            let curUID = eventSoFar["ownerUID"] as! String
            if curUID == uid {
                var eid: String!
                if event == nil {
                    eid = createEventDocument()
                    eventSoFar["eventID"] = eid
                } else {
                    eventSoFar["eventID"] = event.eventID
                }
                imgLoadingFlag = true
                uploadImages(eventId: eid)
                saveToProfile(uid: uid, eid: eid)
            }

            
//            else{
//                imgLoadingFlag = false
//            }
            
            
        }
    }
    
    func getUID() -> String? {
        let user = Auth.auth().currentUser
        if let userID: String = user?.uid {
            return userID
        }
        return nil
    }
    
    func createEventDocument() -> String? {
        var error: Bool = false
        let docRef = db.collection("events").addDocument(data: [
            "exists" : true
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                error = true
            }
        }
        return error ? nil : docRef.documentID
    }
    
    func saveToProfile(uid: String, eid: String){
        let docRef: DocumentReference = db.collection("users").document(uid)
        docRef.updateData(
            [
                "createdEvents": FieldValue.arrayUnion([eid])
            ], completion: {
                err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
        )
    }
    
    func uploadImages(eventId: String) {
//        var noError: Bool
        
//        if (images.count == 0){
//            imgLoadingFlag = false
//            return
//        }
        
        let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        var count: Int = 0 {
            willSet {
                if newValue > images.count {
                    imgLoadingFlag = false
                }
            }
        }
        count += 1
        for image in images {
            let imageId = UUID().uuidString
            if let imageData = image.jpegData(compressionQuality: 4.0) {
                let eventRef = storageRef.child("events").child(eventId).child("\(imageId)")
                eventRef.putData(imageData, metadata: metadata, completion: {
                    (storageMetadata, error) in
                    if error != nil {
                        print("error uploading image \(imageId)")
                        return
                    }
                    //print("no errors")
                    eventRef.downloadURL(completion: { (url, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        //print("no errors 2")

                        guard let url = url else { return }
                        self.imgURLs.append(url.absoluteString)
                        
                        //increment does not allow printing of updated value
                        count += 1
                    })
                })
            }
        }
    }
    
    func uploadCollection() {
        let docRef: DocumentReference = db.collection("events").document(eventSoFar["eventID"] as! String)
        print("Got here")
        var count: Int = 0 {
            willSet {
                if newValue >= questions.count {
                    collectionLoadingFlag = false
                }
            }
        }
        print(eventSoFar)
        docRef.setData(eventSoFar,
            merge: false, completion: {
                err in
                if let err = err {
                    print("Error adding document: \(err)")
                    return
                }
                let qaRef = docRef.collection("QA")
                // on Success, upload questions as well
                for question: Question in self.questions {
                    qaRef.addDocument(data:
                        [
                            "question" : question.question,
                            "answer" : question.answer
                        ], completion: {
                            err in
                            if let err = err {
                                print("Error adding question: \(err)")
                                return
                            }
                            count += 1
                        }
                    )
                }
            }
        )
    }
    

}
extension QAandConfirmVC: UITableViewDelegate, UITableViewDataSource{
    
    
    
    
    func loadTable(){
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    
}
