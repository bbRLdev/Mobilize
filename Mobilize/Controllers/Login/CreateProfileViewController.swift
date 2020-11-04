//
//  CreateProfileViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 10/19/20.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    let segueID = "createProfileSegue"
    
    var email = ""

    //var name, email, photoUrl, uid, emailVerified

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        if(nameField.text == ""){
            statusLabel.text = "Please enter a name."
            return
        }
        else{
            let user = Firebase.Auth.auth().currentUser
//            db.collection("cities").document("BJ").setData([ "capital": true ], merge: true)
            if let userID:String = user?.uid{
                // Add a new document with a generated ID
                //var ref: DocumentReference? = nil
                db.collection("users").document(userID).setData([
                    "name" : nameField.text!,
                    "bio" : bioTextView.text ?? ""
                ], merge: true) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(userID)")
                    }
                }
                
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.displayName = nameField.text!
                //print(nameField.text!)
                changeRequest?.commitChanges { (error) in
                    if(error == nil){
                        //print(Auth.auth().currentUser?.displayName ?? "none")
                        self.performSegue(withIdentifier: self.segueID, sender: nil)
                    }
                }
            }
        }
    }
    
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?


    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().currentUser?.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let user = Auth.auth().currentUser
//        if let user = user {
//            self.nameLabel.text = user.displayName
//
//        }
        handle = Auth.auth().addStateDidChangeListener { (auth, usr) in
            let user = Auth.auth().currentUser
            if let user = user {
                self.nameLabel.text = user.displayName

            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
