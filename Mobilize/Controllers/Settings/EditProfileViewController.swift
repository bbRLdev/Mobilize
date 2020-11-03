//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/15/20.
//
import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var organizationField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    var name = ""
    var organization = ""
    var image:UIImage? = nil
    var profile:UserModel? = nil
    var imagePicker = UIImagePickerController()
    //Split first and last name fields
    
    override func viewDidLoad() {
        profile?.name = "Brandt Swanson"
        profile?.organization = "Antifa president"
        super.viewDidLoad()
        imagePicker.delegate = self
        if let filePath = Bundle.main.path(forResource: profile?.profilePicture, ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
            profilePicture.contentMode = .scaleAspectFit
            profilePicture.image = image
        }
        //organizationField.text = profile!.organization
        nameField.text = profile?.name
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editPhoto(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        /*
        // Create a root reference
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Create a reference to "mountains.jpg"
        let mountainsRef = storageRef.child("mountains.jpg")

        // Create a reference to 'images/mountains.jpg'
        let mountainImagesRef = storageRef.child("images/mountains.jpg")

        // While the file names are the same, the references point to different files
        mountainsRef.name == mountainImagesRef.name;            // true
        mountainsRef.fullPath == mountainImagesRef.fullPath;    // false
            
        if let filePath = Bundle.main.path(forResource: profile?.profilePicture, ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) {
            profilePicture.contentMode = .scaleAspectFit
            profilePicture.image = image
        }*/
    }
    
    @IBAction func save(_ sender: Any) {
        //Save updated info to firebase
    }
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.editedImage] as? UIImage {
            profilePicture.image = image
        }
        dismiss(animated: true, completion: nil)
        reloadInputViews()
    }
}
