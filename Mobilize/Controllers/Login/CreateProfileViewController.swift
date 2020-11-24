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
    
    var login:LoginModel?

    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var organization: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 4
        bioTextView.layer.borderColor = UIColor.lightGray.cgColor
        bioTextView.layer.borderWidth = 1
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
        if segue.identifier == segueID,
           let pictureVC = segue.destination as? UploadPictureViewController {
            pictureVC.delegate = self
            pictureVC.firstName = firstNameField.text!
            pictureVC.lastName = lastNameField.text!
            pictureVC.organization = organization.text!
            pictureVC.bio = bioTextView.text!
            pictureVC.login = login
            }
    }
    
    // remove sofware keyboard from screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
    
}
