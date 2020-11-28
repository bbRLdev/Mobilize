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
import MapKit

class EventDetailsViewController: UIViewController {
    let db = Firestore.firestore()
    let auth = Auth.auth()
    let cellTag = "qCell"
    let imgCollectionSegue = "imageCollectionSegue"
    let qSegue = "qSegue"
    //let homeSegue = "homeSegue"
    
    var disableButtons = false
    
    var eventID: String?
    var userID: String?
    var ownerUID: String?
    var event: EventModel!
    var eventRef: DocumentReference?
    var userRef: DocumentReference?
    
    var blankImage = "PeopleIcon"
    
    var imageArray=[UIImage]()
    
//    @IBOutlet weak var organizerLabel: UILabel!
//
//    @IBOutlet weak var addressLabel: UILabel!
//    @IBOutlet weak  var editButton: UIButton!
//    @IBOutlet weak var stack: UIStackView!
    
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var RSVPButton: UIButton!
    
    @IBOutlet weak var questionButton: UIButton!
    
    @IBOutlet weak var viewProfileButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var RSVPsLabel: UILabel!
    
    @IBOutlet weak var organizationLabel: UILabel!
    
    @IBOutlet weak var creatorLabel: UILabel!
    
    @IBOutlet weak var activismTypeLabel: UILabel!
    
    @IBOutlet weak var eventTypeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var qaTableView: SelfSizingTableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(disableButtons){
            viewProfileButton.isUserInteractionEnabled = false
            viewProfileButton.isEnabled = false
        }
        
        editButton.isHidden = true
        questionButton.isHidden = true
        
        qaTableView.maxHeight = 400
        qaTableView.delegate = self
        qaTableView.dataSource = self
        
        
        titleLabel.numberOfLines = 0
        addressLabel.numberOfLines = 0
        organizationLabel.numberOfLines = 0
        creatorLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        
        likeButton.setTitle("Like", for: .normal)
        likeButton.setTitle("Liked!", for: .selected)
        RSVPButton.setTitle("RSVP", for: .normal)
        RSVPButton.setTitle("RSVP'd!", for: .selected)
        
        let mosaicLayout = MosaicLayout()
        collectionView.frame = self.view.bounds
        collectionView.collectionViewLayout = mosaicLayout
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.isScrollEnabled = false
        collectionView.indicatorStyle = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MosaicCell.self, forCellWithReuseIdentifier: MosaicCell.identifer)
        
        userID = auth.currentUser?.uid
        
        eventRef = self.db.collection("events").document(eventID!)
        userRef = self.db.collection("users").document(userID!)
        loadEventInfo()
        updateLikeButton()
        updateRSVPButton()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
    }
    
    @IBAction func viewMapButtonPressed(_ sender: Any) {
        
        let nav = self.navigationController
        let homeVC = nav!.viewControllers[0] as! HomeViewController
        
        let region = (homeVC.mapView.regionThatFits(MKCoordinateRegion(center: event.coordinates!, latitudinalMeters: 0, longitudinalMeters: 1500)))

        homeVC.mapView.setRegion(region, animated: true)
            
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        likeButton.isUserInteractionEnabled = false
        //let docRef = self.db.collection("events").document(eventID!)
        
        let operation = likeButton.isSelected ? -1 : 1

        eventRef?.updateData([
            "numLikes": FieldValue.increment(Int64(operation))
        ], completion: {
            err in
            if let err = err {
                print("Error updating document: \(err)")
            }
            else{
                //updateLikeButton()
            }
        })
        
        if(operation == 1){
            userRef?.updateData(
                [
                    "likedEvents": FieldValue.arrayUnion([eventID!])
                ], completion: {
                    err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                    else{
                        self.updateLikeButton()
                    }
                }
            )
        }
        else{
            userRef?.updateData(
                [
                    "likedEvents": FieldValue.arrayRemove([eventID!])
                ], completion: {
                    err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                    else{
                        self.updateLikeButton()
                    }
                }
            )
        }
        


    }
    
    @IBAction func RSVPButtonPressed(_ sender: Any) {
        RSVPButton.isUserInteractionEnabled = false
        //let docRef = self.db.collection("events").document(eventID!)
        
        
        let operation = RSVPButton.isSelected ? -1 : 1

        eventRef?.updateData([
            "numRSVPs": FieldValue.increment(Int64(operation))
        ], completion: {
            err in
            if let err = err {
                print("Error updating document: \(err)")
            }
            else{
                //self.updateRSVPButton()
            }
        })
        
        if(operation == 1){
            userRef?.updateData(
                [
                    "rsvpEvents": FieldValue.arrayUnion([eventID!])
                ], completion: {
                    err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                    else{
                        self.updateRSVPButton()
                    }
                }
            )
        }
        else{
            userRef?.updateData(
                [
                    "rsvpEvents": FieldValue.arrayRemove([eventID!])
                ], completion: {
                    err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                    else{
                        self.updateRSVPButton()
                    }
                }
            )
        }

        
        
    }
    
    @IBAction func creatorButtonPressed(_ sender: Any) {
        
        if(event.organizerUID != nil){
            let storyboard: UIStoryboard = UIStoryboard(name: "ProfileStory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
            vc.userID = event.organizerUID
            self.show(vc, sender: self)
        }

    }
    
    @IBAction func questionButtonPressed(_ sender: Any) {
        //segue
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
    }
    
    private func updateLikeButton(){
        //let docRef = self.db.collection("users").document(userID!)
        userRef?.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let liked = dataDescription!["likedEvents"] as? [String] ?? []
                if liked.contains(self.eventID!){
                    self.likeButton.isSelected = true
                }
                else{
                    self.likeButton.isSelected = false
                }
                self.likeButton.isUserInteractionEnabled = true
            }
        }
    }
    private func updateRSVPButton(){
        //let docRef = self.db.collection("users").document(userID!)
        userRef?.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let rsvp = dataDescription!["rsvpEvents"] as? [String] ?? []
                if rsvp.contains(self.eventID!){
                    //print("RSVP'd")
                    //self.RSVPButton.setTitle("RSVP'd!", for: .selected)
                    self.RSVPButton.isSelected = true
                }
                else{
                    //print("did not RSVP")
                    self.RSVPButton.isSelected = false
                    //self.RSVPButton.setTitle("RSVP", for: .normal)
                }
                self.RSVPButton.isUserInteractionEnabled = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == imgCollectionSegue,
           let nextVC = segue.destination as? EventImageViewController{
            //nextVC.images = images
        }
        if segue.identifier == qSegue,
           let nextVC = segue.destination as? AddQ{
            nextVC.eventRef = eventRef
        }

    }
    
    private func setOrganizerName(uid: String) {
        let docRef = self.db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let firstName = dataDescription!["firstName"] as! String
                let lastName = dataDescription!["lastName"] as! String
                self.creatorLabel.text = "Organized by: " + firstName + " " + lastName
            }
        }
        
        
    }
    func loadEventInfo() {
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
                
                let latitude:Double = coordDict.value(forKey: "latitude") as! Double
                let longitude:Double = coordDict.value(forKey: "longitude") as! Double
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                
                var qList: [Question] = []
                
                for qa in questions{
                    qList.append(Question(question: qa.value(forKey: "question") as! String, answer: qa.value(forKey: "answer") as! String))
                }
                
                ownerUID = ownerID
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
                
                var imgCount = 0
                for entry in imgList{
                    event.photoIdCollection[imgCount] = entry.value(forKey: "\(imgCount)") as! String
                    imgCount += 1
                }
                
                let dFormatter = DateFormatter()
                dFormatter.dateStyle = .medium
                dFormatter.timeStyle = .medium
                
                titleLabel.text = event.eventName
                dateLabel.text = dFormatter.string(from: event.date ?? Date())
                addressLabel.text = event.location
                likesLabel.text = String(event.likeNum!)
                RSVPsLabel.text = String(event.rsvpNum!)
                organizationLabel.text = event.organization
                setOrganizerName(uid: event.organizerUID!)
                descriptionLabel.text = event.description
                activismTypeLabel.text = "Activism: " + activismTypeFilter
                eventTypeLabel.text = "Event Type: " + eventTypeFilter
                
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
                
                
                imageArray.append(UIImage(named: blankImage)!)
                //collectionView.reloadData()
                
                let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
                
                let total = event.photoIdCollection.count
                if(total == 0){
                    collectionView.reloadData()
                }
                
                var count = 0
                var empty = true
                var loadedImages = [UIImage](repeating: UIImage(), count: total)
                
                var imgLoadingFlag = false {
                        willSet {
                            if newValue == true {
                                if(!empty){
                                    imageArray = loadedImages
                                }
                                collectionView.reloadData()
                            }
                        }
                }
                
                
                for (i, pid) in event.photoIdCollection.enumerated(){
                    let imgRef = storageRef.child("events/\(eventID!)").child(pid)
                    imgRef.getData(maxSize: 1 * 2048 * 2048, completion: {
                        data, error in
                        if error != nil {
                            let toRemove: NSDictionary = ["id": pid, "index": i]
                            eventRef?.updateData(["photoIDCollection": FieldValue.arrayRemove([toRemove])])
                            print("error getting image")
                        } else {
                            loadedImages[i] = UIImage(data: data!)!
                            empty = false
                        }
                        count += 1
                        if(count >= total){
                            if(!imgLoadingFlag){
                                imgLoadingFlag = true
                            }
                        }
                    })
                }
                
                checkAuth()
                loadTable()
                
                eventRef?.addSnapshotListener { documentSnapshot, error in
                        
                        guard let document = documentSnapshot else {
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                        if let data = document.data(){
                            let dataDescription = data
                            self.event.likeNum = dataDescription["numLikes"] as? Int
                            self.event.rsvpNum = dataDescription["numRSVPs"] as? Int
                            self.likesLabel.text = "\(self.event.likeNum!) likes"
                            self.RSVPsLabel.text = "\(self.event.rsvpNum!) going"
                        }
                    }
                
            }
            
        }

    }
    
    func checkAuth() {
        if let uid = auth.currentUser?.uid{
            if uid != ownerUID {
                questionButton.isHidden = false
            }
        }

    }
}

extension EventDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MosaicCell.identifer, for: indexPath) as? MosaicCell
            else { preconditionFailure("Failed to load collection view cell") }
        
        let imgToAdd = imageArray[indexPath.row]
        
        cell.imageView.image = imgToAdd

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc=ImagePreviewViewController()
        vc.imgArray = self.imageArray
        vc.passedContentOffset = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
        
        //self.performSegue(withIdentifier: imgCollectionSegue, sender: nil)
    }

}

extension EventDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func loadTable(){
        qaTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(event == nil){
            return 0
        }
        return event.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = qaTableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = event.questions[row].question
        cell.detailTextLabel?.text = event.questions[row].answer
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

class AddQ: UIViewController{
    var eventRef: DocumentReference?
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var qTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qTextView.layer.borderColor = UIColor.lightGray.cgColor
        qTextView.layer.borderWidth = 1
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if(qTextView.text != ""){
            let controller = UIAlertController(title: "Confirmation", message: "Submit Question?", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title:"Yes", style: .default, handler: { [self]_ in eventRef?.updateData(["pendingQuestions": FieldValue.arrayUnion([qTextView.text!])])
                self.dismiss(animated: true, completion: nil)
            }))
            controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
            
        }
        

    }
}



class SelfSizingTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    var padding = CGFloat(80)
  
  override func reloadData() {
    super.reloadData()
    self.invalidateIntrinsicContentSize()
    //heightConstraint.constant = contentSize.height
//    UIView.animate(withDuration: 0.2) {
//      self.layoutIfNeeded()
//    }
    
    self.layoutIfNeeded()
  }
  
  override var intrinsicContentSize: CGSize {
    let height = min(contentSize.height + padding , maxHeight)
    //let height = maxHeight
    
    return CGSize(width: contentSize.width, height: height)
  }
}
