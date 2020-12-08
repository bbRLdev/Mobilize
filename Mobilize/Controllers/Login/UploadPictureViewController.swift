//
//  UploadPictureViewController.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/12/20.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import CoreData

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
    var login: LoginModel?
    var user: UserModel?
    
    var pending = UIAlertController(title: "Creating Profile\n\n", message: nil, preferredStyle: .alert)
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet weak var createProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        profilePicture.translatesAutoresizingMaskIntoConstraints = true
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor.gray.cgColor
        profilePicture.layer.borderWidth = 4
        createProfileButton.layer.cornerRadius = 4
    }
    
    @IBAction func choosePicturePressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func createProfileAlertHandler(alert: UIAlertAction!){
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    @IBAction func createProfilePressed(_ sender: Any) {
        
        guard let imageSelected = self.image else {
            let msg = "choose a profile picture"
            let controller = UIAlertController(title: "Error",
                                               message: msg,
                                               preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: nil))
            
            self.present(controller, animated: true, completion: nil)
            return
        }
        
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        displaySignInPendingAlert()
        
        let email = login?.loginID
        let password = login?.password
        
        Auth.auth().createUser(withEmail: email!, password: password!) { [self] user, error in
            if error == nil {
                Auth.auth().signIn(withEmail: email!, password: password!)
                // store the profile now that we have created it
                login?.storeProfile()
                if let userID:String = user?.user.uid {
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
                                // got here... should have all info with no errors
                                self.user = UserModel(uid: userID, first: firstName!, last: lastName!, organization: organization!, bio: bio!, profilePicture: image!, eventsRSVPd: [String](), eventsCreated: [String](), eventsLiked: [String](), loginInfo: login!)
                                
                                pending.dismiss(animated: true, completion: {
                                                    self.performSegue(withIdentifier: "welcomeSegue", sender: nil)})
                            }
                        })
                    })
                }
            }else {
                pending.dismiss(animated: true, completion: {
                    let msg = "Check the validity of your email address. An account may have already been created."
                    let controller = UIAlertController(title: "Error",
                                                       message: msg,
                                                       preferredStyle: .alert)
                    
                    controller.addAction(UIAlertAction(title: "OK",
                                                       style: .default,
                                                       handler: createProfileAlertHandler(alert:)))
                    
                    self.present(controller, animated: true, completion: nil)
                })

            }
        }

    }
    
    func displaySignInPendingAlert() {
        
        // create an activity indicator
        let indicator = UIActivityIndicatorView(frame: pending.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // add the activity indicator as a subview of the alert controller's view
        pending.view.addSubview(indicator)
        // required otherwise if there buttons in the UIAlertController you will not be able to press them
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()

        self.present(pending, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.editedImage] as? UIImage {
            profilePicture.image = image
            self.image = image
        }
        dismiss(animated: true, completion: nil)
        reloadInputViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeSegue",
           let welcomeVC = segue.destination as? WelcomeViewController {
            welcomeVC.user = self.user!
            }
    }
    
}
