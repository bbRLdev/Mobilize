//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/15/20.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import FirebaseStorage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var organizationField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var bioField: UITextView!
    
    var name = ""
    var organization = ""
    var image:UIImage? = nil
    var profile:UserModel?
    var imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor.gray.cgColor
        profilePicture.layer.borderWidth = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadProfileInfo()
        //loadUserModelInfo()
    }
    
    func loadUserModelInfo() {
        self.profilePicture.image = profile?.profilePicture
        self.firstNameField.text = profile?.first
        self.lastNameField.text = profile?.last
        self.organizationField.text = profile?.organization
        self.bioField.text = profile?.bio
    }
    
    @IBAction func editPhoto(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let imageSelected = self.image else {
            print("pic is nil")
            saveTextFields()
            return
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
            return
        }
        let user = Firebase.Auth.auth().currentUser
        if let userID:String = user?.uid {
            
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
                            "profileImageURL": metaImageURL,
                            "firstName": self.firstNameField.text!,
                            "lastName": self.lastNameField.text!,
                            "organization": self.organizationField.text!,
                            "bio": self.bioField.text!
                        ]) { err in
                            if let err = err {
                                print("Error updating profile: \(err)")
                            }
                        }
                    }
                })
            })
        }
        // update user model
        profile?.profilePicture = self.profilePicture.image
        profile?.first = self.firstNameField.text!
        profile?.last =  self.lastNameField.text!
        profile?.organization = self.organizationField.text!
        profile?.bio = self.bioField.text!
    }
    
    func saveTextFields() {
        let user = Firebase.Auth.auth().currentUser
        if let userID:String = user?.uid {
            let userRef = self.db.collection("users").document(userID)
            userRef.updateData([
                "firstName": self.firstNameField.text!,
                "lastName": self.lastNameField.text!,
                "organization": self.organizationField.text!,
                "bio": self.bioField.text!
            ]) { err in
                if let err = err {
                    print("Error updating profile: \(err)")
                }
            }
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
                self.firstNameField.text = firstName
                self.lastNameField.text = lastName
                self.organizationField.text = org
                self.bioField.text = bio
                let urlDatabase = dataDescription!["profileImageURL"] as! String
                let url = URL(string: urlDatabase)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print("error retrieving image")
                        return
                    }
                    DispatchQueue.main.async {
                        self.profilePicture.image = UIImage(data: data!)
                    }
                }).resume()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        print("GOT TO FINISH PICKING METHOD")
        if let image = info[.editedImage] as? UIImage {
            profilePicture.image = image
            self.image = image
        }
        dismiss(animated: true, completion: nil)
        reloadInputViews()
    }
    
}


