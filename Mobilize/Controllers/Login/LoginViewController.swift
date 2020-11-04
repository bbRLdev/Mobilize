//
//  LoginViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/15/20.
//

import UIKit
import Firebase
import CoreData

class LoginViewController: UIViewController {

    
    let segueID0 = "loginSegue"
    
    let segueID1 = "signupSegue"
    

    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var cPasswordTextField: UITextField!

    @IBOutlet weak var cPasswordLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cPasswordLabel.isHidden = true
        cPasswordTextField.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch segCtrl.selectedSegmentIndex {
        case 0:
            cPasswordLabel.isHidden = true
            cPasswordTextField.isHidden = true
            loginButton.setTitle("Sign In", for: .normal)
        case 1:
            cPasswordLabel.isHidden = false
            cPasswordTextField.isHidden = false
            loginButton.setTitle("Sign Up", for: .normal)
        default:
            print("error")
            
        }
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        statusLabel.text = nil

        guard let uid = usernameTextField.text,
              let password = passwordTextField.text,
              uid.count > 0,
              password.count > 0
        else {
            statusLabel.text = "Please try again"
          return
        }


        if(cPasswordLabel.isHidden) {
            Auth.auth().signIn(withEmail: uid, password: password) {
              user, error in
                if let _ = error, user == nil {
                self.statusLabel.text = "Sign in failed"
              }else {
                // store login info
                self.storeProfile(uid: uid, password: password)
                self.performSegue(withIdentifier: self.segueID0, sender: nil)
              }
            }
        }else {
            // 1
            guard let cPassword = cPasswordTextField.text,
                  password == cPassword
            else{
                statusLabel.text = "Sign up failed, please review your entries"
                return
            }

            // 2
            Auth.auth().createUser(withEmail: uid, password: password) { user, error in
                if error == nil {
                    Auth.auth().signIn(withEmail: uid, password: password)
                    // store login info
                    self.storeProfile(uid: uid, password: password)
                    self.performSegue(withIdentifier: self.segueID1, sender: nil)

                }else {
                    self.statusLabel.text = "Sign up failed, please review your entries"
                }
            }

        }
    }
    
    // helper method that saves login information into core data
    private func storeProfile(uid:String, password:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let profileToStore = NSEntityDescription.insertNewObject(forEntityName: "ProfileEntity", into:context)
        // set the attribute variables
        profileToStore.setValue(uid, forKey: "uid")
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
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
        
}
