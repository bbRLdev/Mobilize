//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/15/20.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let options = ["Your events", "Settings"]
    let cellTag = "cell"
    
    var profile:UserModel!
    
    @IBOutlet var name: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var Options: UITableView!
    @IBOutlet var organization: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Options.delegate = self
        Options.dataSource = self
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.layer.borderColor = UIColor.gray.cgColor
        profilePic.layer.borderWidth = 4
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(false)
//        loadProfileInfo()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(false)
        loadProfileInfo()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        //print(row)
        cell.textLabel?.text = options[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            performSegue(withIdentifier: "events", sender: self)
        }
        if(indexPath.row == 1) {
            performSegue(withIdentifier: "settings", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "events",
           let nextVC = segue.destination as? ProfileEventsViewController {
            nextVC.uid = Auth.auth().currentUser?.uid
        }
    }
    
    func loadProfileInfo() {
        let userID = Auth.auth().currentUser?.uid
        let docRef = self.db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let firstName = dataDescription!["firstName"] as! String
                let lastName = dataDescription!["lastName"] as! String
                let org = dataDescription!["organization"] as! String
                let bio = dataDescription!["bio"] as! String
                
                //
                //needs more work
                //self.profile = UserModel(uid: userID!, first: firstName, last: lastName, organization: org, bio: bio, profilePicture: "", eventsRSVPd: [], eventsCreated: [], eventsLiked: [])
                
                
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
}
