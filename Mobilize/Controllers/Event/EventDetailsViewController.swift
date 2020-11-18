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
    let cellTag = "qCell"
    let imgCollectionSegue = "imageCollectionSegue"
    
    var eventID: String?
    var ownerUID: String = ""
    var event: EventModel!
    
    var imageData = ["BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile"]
    
//    @IBOutlet weak var organizerLabel: UILabel!
//
//    @IBOutlet weak var addressLabel: UILabel!
//    @IBOutlet weak  var editButton: UIButton!
//    @IBOutlet weak var stack: UIStackView!
    
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var organizationLabel: UILabel!
    
    @IBOutlet weak var creatorLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var qaTableView: SelfSizingTableView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //    @IBOutlet weak var imagePreview0: UIImageView!
//
//    @IBOutlet weak var imagePreview1: UIImageView!
//
//    @IBOutlet weak var imagePreview2: UIImageView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.isHidden = true
        
        qaTableView.maxHeight = 400
        qaTableView.delegate = self
        qaTableView.dataSource = self
        
        titleLabel.numberOfLines = 0
        addressLabel.numberOfLines = 0
        organizationLabel.numberOfLines = 0
        creatorLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        
        let mosaicLayout = MosaicLayout()
        collectionView.frame = self.view.bounds
        collectionView.collectionViewLayout = mosaicLayout
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.isScrollEnabled = false
        collectionView.indicatorStyle = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MosaicCell.self, forCellWithReuseIdentifier: MosaicCell.identifer)
        
        loadEventInfo()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
    }
    
    @IBAction func viewMapButtonPressed(_ sender: Any) {
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
    }
    
    @IBAction func RSVPButtonPressed(_ sender: Any) {
    }
    
    @IBAction func creatorButtonPressed(_ sender: Any) {
    }
    
    @IBAction func questionButtonPressed(_ sender: Any) {
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == imgCollectionSegue,
               let nextVC = segue.destination as? EventImageViewController{
                //nextVC.images = images
            }
    }
    
    private func setOrganizerName(uid: String) {
        let docRef = self.db.collection("users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let firstName = dataDescription!["firstName"] as! String
                let lastName = dataDescription!["lastName"] as! String
                self.creatorLabel.text = firstName + " " + lastName
            }
        }
        
        
    }
    func loadEventInfo() {
        let eid = eventID
        let docRef = self.db.collection("events").document(eid!)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
//                let addr = dataDescription!["address"] as! String
//                self.addressLabel.text = addr
//                let uid = dataDescription!["ownerUID"] as! String
//                self.ownerUID = uid
                //print(self.ownerUID)
                
                let address = dataDescription!["address"] as! String
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
                
                ownerUID = ownerID
                event = EventModel()
                event.location = address
                event.coordinates = coordinates
                event.description = eventDesc
                event.photoURLCollection = imgList //change later
                event.eventName = eventName
                event.likeNum = likes
                event.rsvpNum = RSVPs
                event.organization = orgName
                event.organizerUID = ownerID
                event.questions = qList
                
                print(event.location!)
                print(event.coordinates!)
                print(event.description!)
                print(event.photoURLCollection)
                print(event.eventName!)
                print(event.likeNum!)
                print(event.rsvpNum!)
                print(event.organization!)
                print(event.organizerUID!)
                print(event.questions)
                
                titleLabel.text = event.eventName
                dateLabel.text = "11/11/11"
                addressLabel.text = event.location
                likesLabel.text = String(event.likeNum!)
                organizationLabel.text = event.organization
                setOrganizerName(uid: event.organizerUID!)
                descriptionLabel.text = event.description
                
                
                checkAuth()
                loadTable()
                
            }
            
        }
    }
    
    func checkAuth() {
        if (auth.currentUser == nil){
            //print("user is nil")
        }
        else{
            //print("user is not nil")
        }
        if let uid = auth.currentUser?.uid{
            //print(uid)
            //print(ownerUID)
            
            if uid == ownerUID {
                //print("i am the creator")
                editButton.isHidden = false
                
            }
        }

    }


}

extension EventDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MosaicCell.identifer, for: indexPath) as? MosaicCell
            else { preconditionFailure("Failed to load collection view cell") }
        
        let curImageName = imageData[indexPath.row]

        let imgToAdd = UIImage(named:curImageName)!
        
        cell.imageView.image = imgToAdd

//        if !assets.isEmpty {
//            let assetIndex = indexPath.item % assets.count
//            let asset = assets[assetIndex]
//            let assetIdentifier = asset.localIdentifier
//
//            cell.assetIdentifier = assetIdentifier
//
//            PHImageManager.default().requestImage(for: asset, targetSize: cell.frame.size,
//                                                  contentMode: .aspectFill, options: nil) { (image, hashable)  in
//                                                    if let loadedImage = image, let cellIdentifier = cell.assetIdentifier {
//
//                                                        // Verify that the cell still has the same asset identifier,
//                                                        // so the image in a reused cell is not overwritten.
//                                                        if cellIdentifier == assetIdentifier {
//                                                            cell.imageView.image = loadedImage
//                                                        }
//                                                    }
//            }
//        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: imgCollectionSegue, sender: nil)
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
        cell.textLabel?.text = event.questions[row].question
        cell.detailTextLabel?.text = event.questions[row].answer
        //cell.textLabel?.text = questions[row].
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        qaTableView.deselectRow(at: indexPath, animated: true)
        

    }
    
}

class SelfSizingTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    var padding = CGFloat(30)
  
  override func reloadData() {
    super.reloadData()
    self.invalidateIntrinsicContentSize()
    //heightConstraint.constant = tableView.contentSize.height
//    UIView.animate(withDuration: 0.2) {
//      self.layoutIfNeeded()
//    }
    
    self.layoutIfNeeded()
  }
  
  override var intrinsicContentSize: CGSize {
    let height = min(contentSize.height + padding , maxHeight)
    return CGSize(width: contentSize.width, height: height)
  }
}
