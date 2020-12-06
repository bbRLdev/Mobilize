//
//  ProfileViewController.swift
//  Mobilize
//
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //let options = ["Your events", "Settings"]
    var createdEvents:[String] = []
    let cellTag = "cell"
    
    var profile:UserModel!
    var userID:String?
   
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var organization: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.layer.borderColor = UIColor.gray.cgColor
        profilePic.layer.borderWidth = 4
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(false)
        loadProfileInfo()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createdEvents.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?{
      return "Created Events"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        //cell.textLabel?.numberOfLines = 0
        
        let eid = createdEvents[row]
        
        let docRef = self.db.collection("events").document(eid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let eventName = dataDescription!["name"] as? String
                
                cell.textLabel?.text = eventName
                
                //cell.detailTextLabel?.text = date

            } else {
                print("Document does not exist")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
        vc.eventID = createdEvents[indexPath.row]
        vc.disableButtons = true
        self.show(vc, sender: self)
    }
    

    
    func loadProfileInfo() {
        let docRef = self.db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let firstName = dataDescription!["firstName"] as! String
                let lastName = dataDescription!["lastName"] as! String
                let org = dataDescription!["organization"] as! String
                let bio = dataDescription!["bio"] as! String
                self.createdEvents = dataDescription!["createdEvents"] as? [String] ?? []
                
                
               DispatchQueue.main.async { self.tableView.reloadData() }
               self.checkData(userRef: docRef)
                
                self.name.text = firstName + " " + lastName
                self.organization.text = org
                self.bioTextView.text = bio
                let urlDatabase = dataDescription!["profileImageURL"] as! String
                let url = URL(string: urlDatabase)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print("error retrieving image")
                        return
                    }
                    DispatchQueue.main.async {
                        self.profilePic.image = UIImage(data: data!)
                    }
                }).resume()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func checkData(userRef: DocumentReference){
        let createdList = createdEvents
        
        for created in createdList{
            let eventRef = self.db.collection("events").document(created)
            eventRef.getDocument{ (document, error) in
                if let document = document, document.exists{}
                else{
                    if let idx = self.createdEvents.firstIndex(of: created){
                        self.createdEvents.remove(at: idx)
                        DispatchQueue.main.async { self.tableView.reloadData() }
                    }
                    userRef.updateData(["createdEvents": FieldValue.arrayRemove([created])])
                }

            }
        }
    }

}

