//
//  QAandConfirmVC.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/22/20.
//

//MARK: TODO: remove image ref from event.photoIDCollection when deleting
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UserNotifications


class QAandConfirmVC: UIViewController {
    //var q: Question = (question: "Is america dumb af", answer: "Yes")
    let db = Firestore.firestore()
    let cellTag = "tag"
    let segueIdentifier0 = "editSegue"
    let segueIdentifier1 = "addSegue"
    
    var images: [UIImage?] = []
    var event: EventModel!
    var eventSoFar: [String : Any] = [:]
    var imgURLs: [String] = []
    var imgRefList = [[String : String]]()
    var questions: [Question] = []
    
    var dateComponents: DateComponents?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var qaTableView: UITableView!
    
    var imgLoadingFlag = false {
            willSet {
                if newValue == false {
                    //questions.append(q)
                    collectionLoadingFlag = true
                    uploadCollection()
                }
            }
    }
        
    var collectionLoadingFlag = false {
        willSet {
            if newValue == false {
                saveToProfile(uid: eventSoFar["ownerUID"] as! String,
                              eid: eventSoFar["eventID"] as! String)
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
        createButton.layer.cornerRadius = 4
        addButton.layer.cornerRadius = 4
        //print("Did load \(images)")
        qaTableView.delegate = self
        qaTableView.dataSource = self
        if event != nil {
            questions = event.questions
        }       
    }
  
    override func viewWillAppear(_ animated: Bool) {
        //qaTableView.reloadData()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if(qaTableView.isEditing){
            navigationItem.rightBarButtonItem?.style = .plain
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
        else{
            navigationItem.rightBarButtonItem?.style = .done
            navigationItem.rightBarButtonItem?.title = "Done"
        }
        qaTableView.isEditing = !qaTableView.isEditing
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
                //check if event So Far has any photo ids in delete
                // field and handle requests if necessary
                // deleteImages(eventID: eid)
                uploadNewImages(eventId: eventSoFar["eventID"] as? String ?? "")
                // set notification timer
                setNotificationTimer()
            }
//            else{
//                imgLoadingFlag = false
//            }
        }
    }
    
    func setNotificationTimer() {
        
        let content = UNMutableNotificationContent()
        content.title = eventSoFar["name"] as! String + " is starting now!"
        content.body = "Tap here to view more"
        content.sound = UNNotificationSound.default
                        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents!, repeats: false)
        let request = UNNotificationRequest(identifier: eventSoFar["eventID"] as! String, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
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
    
    func uploadNewImages(eventId: String) {
        if(images.count == 0){
            imgLoadingFlag = false
            return
        }

        let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpg"
        var count: Int = 0 {
            willSet {
                if newValue >= images.count {
                    eventSoFar["photoIDCollection"] = imgRefList
                    imgLoadingFlag = false
                }
            }
        }
        var removedCount: Int = 0
        for image in images {
         
            let placeholderImage = UIImage(systemName: "questionmark")

            if image != nil && image!.isEqual(placeholderImage) {
                images.remove(at: count - removedCount)
                print("hello1\(count)")
                count += 1
                
                removedCount += 1
            } else {
                let imageId = UUID().uuidString
                if let imageData = image?.jpegData(compressionQuality: 4.0) {
                    let eventRef = storageRef.child("events").child(eventId).child("\(imageId)")
                    
                    print(eventRef)
                    eventRef.putData(imageData, metadata: metadata, completion: {
                        (storageMetadata, error) in
                        if error != nil {
                            print("error uploading image \(imageId)")
                            return
                        }
                        let temp: [String:String] = self.imgRefList.count != 0
                            ? ["\(count)" : imageId]
                            : ["0" : imageId]
                        self.imgRefList.append(temp)
                        print("hello2\(count)")
                        count += 1
                    })
                }
            }
        }
    }
    
    func uploadCollection() {
        
        let docRef: DocumentReference = db.collection("events").document(eventSoFar["eventID"] as! String)
        var questionsList = [[String:String]]()
        
        for question: Question in questions{
            let temp: [String:String] = ["question": question.question, "answer": question.answer]
            questionsList.append(temp)
        }
        eventSoFar["questions"] = questionsList
        docRef.setData(eventSoFar,
            merge: false, completion: {
                err in
                if let err = err {
                    print("Error adding document: \(err)")
                    return
                }
                else{
                    self.collectionLoadingFlag = false
                }
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueIdentifier0,
            let destination = segue.destination as? addQA,
            let index = qaTableView.indexPathForSelectedRow?.row
            {
            destination.delegate = self

            destination.question = questions[index].question
            destination.answer = questions[index].answer
            destination.index = index
            
        }
        if segue.identifier == segueIdentifier1,
           let destination = segue.destination as? addQA{
            destination.delegate = self
        }
    }

}

extension QAandConfirmVC: UITableViewDelegate, UITableViewDataSource {
    
    func loadTable(){
        qaTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = qaTableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        //cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = questions[row].question
        cell.detailTextLabel?.text = questions[row].answer
        //cell.textLabel?.text = questions[row].
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        qaTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            questions.remove(at: indexPath.row)
            qaTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to: IndexPath) {
        let itemToMove = questions[indexPath.row]
        questions.remove(at: indexPath.row)
        questions.insert(itemToMove, at: to.row)
    }
    
}

class addQA: UIViewController, UITextViewDelegate {
    @IBOutlet weak var qTextView: UITextView!
    @IBOutlet weak var aTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: UIViewController!
    var index = -1
    
    var question = ""
    var answer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 4
        qTextView.delegate = self
        aTextView.delegate = self
        qTextView.layer.borderColor = UIColor.lightGray.cgColor
        qTextView.layer.borderWidth = 1
        aTextView.layer.borderColor = UIColor.lightGray.cgColor
        aTextView.layer.borderWidth = 1
        qTextView.isScrollEnabled = false
        aTextView.isScrollEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        qTextView.text = question
        aTextView.text = answer
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let otherVC = delegate as! QAandConfirmVC
        
        if(qTextView.text != "" && aTextView.text != ""){
            if(index == -1){
                otherVC.questions.append(Question(question: qTextView.text, answer: aTextView.text))
            }
            else{
                otherVC.questions[index].question = qTextView.text
                otherVC.questions[index].answer = aTextView.text
            }
        }

        otherVC.qaTableView.reloadData()
        //print(otherVC.questions[0].question)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
