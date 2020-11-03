//
//  CreateProfileViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 10/19/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class CreateProfileViewController: UIViewController {
    
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
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if(firstNameField.text == ""){
            statusLabel.text = "Please enter a name."
            return
        }else {
            self.performSegue(withIdentifier: self.segueID, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue calculator
        if segue.identifier == segueID,
           let pictureVC = segue.destination as? UploadPictureViewController {
            pictureVC.delegate = self
            pictureVC.firstName = firstNameField.text!
            pictureVC.lastName = lastNameField.text!
            pictureVC.organization = organization.text!
            pictureVC.bio = bioTextView.text!
            }
            
    }
    
}

class UploadPictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let db = Firestore.firestore()
    
    var delegate: UIViewController!
    
    let segueID = "createProfileSegue"
    
    var imagePicker = UIImagePickerController()
    
    var image: UIImage? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var organization: String? = nil
    var bio: String? = nil
    
    
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
        
        let user = Firebase.Auth.auth().currentUser
        if let userID:String = user?.uid {
            // Add a new document with a generated ID
            db.collection("users").document(userID).setData([
                "firstName" : firstName!,
                "lastName" : lastName!,
                "organization" : organization!,
                "bio" : bio!
            ], merge: true) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(userID)")
                }
            }
            let changeRequest = user?.createProfileChangeRequest()
            changeRequest?.displayName = firstName!
            changeRequest?.commitChanges { (error) in
                if(error == nil){
                    print("current display name: " + (Auth.auth().currentUser?.displayName)!)
                    self.performSegue(withIdentifier: self.segueID, sender: nil)
                }
            }
        }
       
//        guard let imageSelected = self.image else {
//            print("profile picture is nil")
//            return
//        }
//
//        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
//            return
//        }
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
                print("label in welcome VC: " + user.displayName!)
                self.nameLabel.text = user.displayName
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
