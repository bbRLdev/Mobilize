//
//  ProfileViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/18/20.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profilePic: UIImageView!
    
    //Table with tabs at top to go between events organizing and RSVPs
    @IBOutlet var eventTable: UITableView!
    
    let db = Firestore.firestore()
    let cellTag = "cell"
    let model: [String] = ["Organizing","RSVP'd Events"]
    var RSVPView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTable.delegate = self
        eventTable.dataSource = self
        displayCurrentPicture()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        if(RSVPView) {
            cell.textLabel?.text = "RSVP Event"
        } else {
            cell.textLabel?.text = "Organizing Event"
        }
        return cell
    }
 
    @IBAction func RSVP(_ sender: Any) {
        RSVPView = true
        DispatchQueue.main.async { self.eventTable.reloadData() }
    }
    @IBAction func organizingEvent(_ sender: Any) {
        RSVPView = false
        DispatchQueue.main.async { self.eventTable.reloadData() }
    }
    
    func displayCurrentPicture() {
        let userID = Auth.auth().currentUser?.uid
        let docRef = self.db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
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
}
