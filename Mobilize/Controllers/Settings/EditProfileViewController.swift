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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.image = image
        organizationField.text = organization
        nameField.text = name
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editPhoto(_ sender: Any) {
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
}
