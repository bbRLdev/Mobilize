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
        
        guard let imageSelected = self.image else {
            print("pic is nil")
            return
        }
        
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        
        let user = Firebase.Auth.auth().currentUser
        if let userID:String = user?.uid {
            // Add a new document with a generated ID
            db.collection("users").document(userID).setData([
                "firstName" : firstName!,
                "lastName" : lastName!,
                "organization": organization!,
                "bio" : bio!,
                "profileImageURL" : ""
            ], merge: true) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(userID)")
                }
            }
            
            let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
            let storageProfileRef = storageRef.child("users").child(userID).child("profile_picture")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageProfileRef.putData(imageData, metadata: metadata, completion: {
                (storageMetadata, error) in
                if error != nil {
                    print("error uploading profile image")
                    return
                }
                
                storageProfileRef.downloadURL(completion: { (url, error) in
                    if let metaImageURL = url?.absoluteString {
                        let userRef = self.db.collection("users").document(userID)
                        userRef.updateData([
                            "profileImageURL": metaImageURL
                        ]) { err in
                            if let err = err {
                                print("Error updating profile image: \(err)")
                            }
                        }
                    }
                })
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.editedImage] as? UIImage {
            profilePicture.image = image
            self.image = image
        }
        dismiss(animated: true, completion: nil)
        reloadInputViews()
    }
    
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().currentUser?.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, usr) in
            let userID = Auth.auth().currentUser?.uid
            let docRef = self.db.collection("users").document(userID!)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    let firstName:String = dataDescription!["firstName"] as! String
                    self.nameLabel.text = firstName
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
