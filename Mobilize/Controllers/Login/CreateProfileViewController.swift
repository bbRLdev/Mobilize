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
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Firebase.Auth.auth().currentUser
        //user = Firebase.Auth.auth().currentUser
        if (user != nil) {
          //name = user.displayName;
            emailLabel.text = user?.email ?? "none"
          //photoUrl = user.photoURL;
          //emailVerified = user.emailVerified;
          //uid = user.uid;  // The user's ID, unique to the Firebase project. Do NOT use
                           // this value to authenticate with your backend server, if
                           // you have one. Use User.getToken() instead.
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        if(nameField.text == ""){
            statusLabel.text = "Please enter a name."
            return
        }
        else{
            let user = Firebase.Auth.auth().currentUser
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?


    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().currentUser?.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
