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
    
    let segueID = "uploadPictureSegue"
    
    var email = ""

    //var name, email, photoUrl, uid, emailVerified

    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var organization: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        if(firstNameField.text == ""){
            statusLabel.text = "Please enter a name."
            return
        }else {
            let user = Firebase.Auth.auth().currentUser
//            db.collection("cities").document("BJ").setData([ "capital": true ], merge: true)
            if let userID:String = user?.uid{
                // Add a new document with a generated ID
                //var ref: DocumentReference? = nil
                db.collection("users").document(userID).setData([
                    "firstName" : firstNameField.text!,
                    "lastName" : lastNameField.text!,
                    "organization" : organization.text!,
                    "bio" : bioTextView.text ?? ""
                ], merge: true) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(userID)")
                    }
                }
                
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.displayName = firstNameField.text!
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

class UploadPictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let segueID = "createProfileSegue"
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    @IBAction func choosePicturePressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createProfilePressed(_ sender: Any) {
        self.performSegue(withIdentifier: self.segueID, sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.editedImage] as? UIImage {
            profilePicture.image = image
        }
        dismiss(animated: true, completion: nil)
        reloadInputViews()
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
