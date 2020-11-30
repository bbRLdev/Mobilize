//
//  PendingQuestionsViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/21/20.
//

import UIKit
import Firebase
import CoreLocation

class PendingQuestionsViewController: UIViewController {
    private let refreshControl = UIRefreshControl()

    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editEventButton: UIButton!
    
    var event: EventModel!
    var eventID:String?
    var eventRef: DocumentReference?
    
    var pendingQuestions:[String] = []
    
    var imageArray=[UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        eventRef = self.db.collection("events").document(eventID!)
        loadEventInfo()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshTable()
    }
    
    @objc private func refreshTable() {
        loadQuestions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if(tableView.isEditing){
            navigationItem.rightBarButtonItem?.style = .plain
            navigationItem.rightBarButtonItem?.title = "Edit"
            
            let docRef = self.db.collection("events").document(eventID!)
            let listName = "pendingQuestions"

            docRef.updateData([
                listName: pendingQuestions
            ], completion: {
                err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            })

        }
        else{
            navigationItem.rightBarButtonItem?.style = .done
            navigationItem.rightBarButtonItem?.title = "Done"
        }
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func editEventButtonPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateEventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "eventInfo") as! EventInfoViewController
        vc.event = event
        vc.coordinates = event.coordinates
        self.show(vc, sender: self)
    }
    
    @IBAction func deleteEventButtonPressed(_ sender: Any) {
        let eid = eventID
        let uid = Auth.auth().currentUser?.uid
        
        let msg = "Are you sure you want to delete this event? This action cannot be undone."
        
        
        let controller = UIAlertController(title: "Delete Event", message: msg, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title:"Yes", style: .destructive, handler: {_ in
            self.db.collection("users").document(uid!).updateData(["createdEvents": FieldValue.arrayRemove([eid!])])

            self.db.collection("events").document(eid!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("removing event")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)


        
    }
    
    
    @IBAction func viewButtonPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
        vc.eventID = eventID
        self.show(vc, sender: self)
    }
    

    private func loadQuestions(){
        let eid = eventID
        let docRef = self.db.collection("events").document(eid!)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.pendingQuestions = dataDescription?["pendingQuestions"] as? [String] ?? []
                
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func loadEventInfo() {
        editEventButton.isUserInteractionEnabled = false
        editEventButton.isEnabled = false
        
        eventRef?.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let activismTypeFilter = dataDescription?["activismTypeFilter"] as! String
                let eventTypeFilter = dataDescription?["eventTypeFilter"] as! String
                let address = dataDescription!["address"] as! String
                let coordDict = dataDescription!["coordinates"] as! NSDictionary
                let date = dataDescription!["date"] as! Timestamp
                let eventDesc = dataDescription!["description"] as! String
                let imgList = dataDescription!["photoIDCollection"] as? [NSDictionary] ?? []
                let eventName = dataDescription!["name"] as! String
                let likes = dataDescription!["numLikes"] as! Int
                let RSVPs = dataDescription!["numRSVPs"] as! Int
                let orgName = dataDescription!["orgName"] as! String
                let ownerID = dataDescription!["ownerUID"] as! String
                let questions = dataDescription!["questions"] as? [NSDictionary] ?? []
                let pQuestions = dataDescription!["pendingQuestions"] as? [String] ?? []
                print("pendingQuestions: ", pendingQuestions)
                let latitude:Double = coordDict.value(forKey: "latitude") as! Double
                let longitude:Double = coordDict.value(forKey: "longitude") as! Double
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                
                var qList: [Question] = []
                
                for qa in questions{
                    qList.append(Question(question: qa.value(forKey: "question") as! String, answer: qa.value(forKey: "answer") as! String))
                }
                
                pendingQuestions = pQuestions
                
                event = EventModel()
                event.eventID = eventID
                event.location = address
                event.coordinates = coordinates
                event.date = date.dateValue()
                event.description = eventDesc
                event.eventName = eventName
                event.likeNum = likes
                event.rsvpNum = RSVPs
                event.organization = orgName
                event.organizerUID = ownerID
                event.questions = qList
                event.photoIdCollection = Array(repeating: "", count: imgList.count)
                
                var count = 0
                for entry in imgList{
                    event.photoIdCollection[count] = entry.value(forKey: "\(count)") as! String
                    count += 1
                }
                
                var aFilter: EventModel.ActivismFilterType?
                var eFilter: EventModel.EventFilterType?
                
                for activism in EventModel.ActivismFilterType.allCases{
                    if(activism.rawValue == activismTypeFilter){
                        aFilter = activism
                        break
                    }
                }
                
                for event in EventModel.EventFilterType.allCases{
                    if(event.rawValue == eventTypeFilter){
                        eFilter = event
                        break
                    }
                }
                
                event.activismType = aFilter?.rawValue
                event.eventType = eFilter?.rawValue
                
                editEventButton.isUserInteractionEnabled = true
                editEventButton.isEnabled = true
                
                
//                imageArray.append(UIImage(named: blankImage)!)
//                //collectionView.reloadData()
//                
//                let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
//                
//                let total = event.photoURLCollection.count
//                if(total == 0){
//                    collectionView.reloadData()
//                }
//                
//                var count = 0
//                var empty = true
//                var loadedImages = [UIImage](repeating: UIImage(), count: total)
//                
//                var imgLoadingFlag = false {
//                        willSet {
//                            if newValue == true {
//                                if(!empty){
//                                    imageArray = loadedImages
//                                }
//                                //collectionView.reloadData()
//                            }
//
//                        }
//                }
            
//                for (i, pid) in event.photoURLCollection.enumerated(){
//                    let imgRef = storageRef.child("events/\(eventID!)").child(pid)
//                    imgRef.getData(maxSize: 1 * 2048 * 2048, completion: {
//                        data, error in
//                        if error != nil {
//                            print("error getting image")
//                        } else {
//                            loadedImages[i] = UIImage(data: data!)!
//                            empty = false
//                        }
//                        count += 1
//                        if(count >= total){
//                            if(!imgLoadingFlag){
//                                imgLoadingFlag = true
//                            }
//                        }
//                    })
//                }
//                

                
            }
            
        }

    }

}

extension PendingQuestionsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?{
      return "Pending Questions"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "qCell", for: indexPath)
        
        cell.textLabel?.text = pendingQuestions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row

        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AnswerQuestion") as! AnswerQuestionViewController
        
        vc.modalPresentationStyle = .pageSheet
        vc.question = pendingQuestions[row]
        vc.indexPath = indexPath
        vc.parentVC = self

        self.present(vc, animated: true, completion: nil)

    }
    
    func deleteHandler(indexPath: IndexPath){
        let row = indexPath.row
        
        let toRemove = pendingQuestions[row]
        pendingQuestions.remove(at: indexPath.row)

        db.collection("events").document(eventID!).updateData(["pendingQuestions": FieldValue.arrayRemove([toRemove])],
            completion: {
            err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        })

        self.tableView.deleteRows(at: [indexPath], with: .left)

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteHandler(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to: IndexPath) {
        let itemToMove = pendingQuestions[indexPath.row]
        pendingQuestions.remove(at: indexPath.row)
        pendingQuestions.insert(itemToMove, at: to.row)
        
    }
}

class AnswerQuestionViewController : UIViewController{
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var qTextView: UITextView!
    
    @IBOutlet weak var aTextView: UITextView!
    
    var question = ""
    var indexPath:IndexPath?
    var parentVC:PendingQuestionsViewController?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        qTextView.text = question
        qTextView.layer.borderColor = UIColor.lightGray.cgColor
        qTextView.layer.borderWidth = 1
        aTextView.layer.borderColor = UIColor.lightGray.cgColor
        aTextView.layer.borderWidth = 1
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if(aTextView.text != ""){
            let controller = UIAlertController(title: "Save Question", message: "Choosing yes will save the response to the event page.", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title:"Yes", style: .default, handler: { [self]_ in
                parentVC?.deleteHandler(indexPath: indexPath!)
                let eid = parentVC?.eventID
                
                let temp: [String:String] = ["question": qTextView.text, "answer": aTextView.text]
                let docRef = db.collection("events").document(eid!)
                docRef.updateData(["questions": FieldValue.arrayUnion([temp])])
                self.dismiss(animated: true, completion: nil)
            }))
            controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)

        }

        
    }
    
    
}
