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
import CoreData

class CreateProfileViewController: UIViewController {
    
    let segueID = "uploadPictureSegue"
    
    var email = ""
    var password = ""

    //var name, email, photoUrl, uid, emailVerified

    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var organization: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if(firstNameField.text == "" || lastNameField.text == ""){
            let msg = "please enter profile information"
            let controller = UIAlertController(title: "Missing fields",
                                               message: msg,
                                               preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: nil))
            
            present(controller, animated: true, completion: nil)
        }
        else{
            self.performSegue(withIdentifier: segueID, sender: nil)
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
            pictureVC.email = email
            pictureVC.password = password
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
    var email = ""
    var password = ""
    
    
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
    
    private func createProfileAlertHandler(alert: UIAlertAction!){
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    private func storeProfile(email:String, password:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let profileToStore = NSEntityDescription.insertNewObject(forEntityName: "ProfileEntity", into:context)
        // set the attribute variables
        profileToStore.setValue(email, forKey: "uid")
        profileToStore.setValue(password, forKey: "password")
        // commit the changes
        do {
            try context.save()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
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
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] user, error in
            if error == nil {
                Auth.auth().signIn(withEmail: email, password: password)
//                let user = Firebase.Auth.auth().currentUser
                //user?.user.uid
                self.storeProfile(email: email, password: password)
                
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
                            }
                        })
                    })
                }
                self.performSegue(withIdentifier: "welcomeSegue", sender: nil)
            }else {
                let msg = "check the validity of your email address"
                let controller = UIAlertController(title: "Error",
                                                   message: msg,
                                                   preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK",
                                                   style: .default,
                                                   handler: createProfileAlertHandler(alert:)))
                
                self.present(controller, animated: true, completion: nil)

            }
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
//        let user = Auth.auth().currentUser
//        if let user = user {
//            self.nameLabel.text = user.displayName
//
//        }
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
