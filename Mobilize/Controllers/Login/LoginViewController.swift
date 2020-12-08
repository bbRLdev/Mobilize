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
    
    var login:LoginModel?
    
    var user:UserModel?
    
    @IBOutlet weak var hidePasswordButton: UIButton!
    
    @IBOutlet weak var cHidePasswordButton: UIButton!
    
    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var cPasswordTextField: UITextField!

    @IBOutlet weak var cPasswordLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    let userNotification = Notification.Name(rawValue: "userModelNotificationKey")
    
    var pending = UIAlertController(title: "Signing in\n\n", message: nil, preferredStyle: .alert)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cPasswordLabel.isHidden = true
        cPasswordTextField.isHidden = true
        cHidePasswordButton.isHidden = true
        loginButton.layer.cornerRadius = 4
        passwordTextField.isSecureTextEntry = true
        cPasswordTextField.isSecureTextEntry = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func hidePasswordPressed(_ sender: Any) {
        hidePasswordHelper()
    }
    
    @IBAction func cHidePasswordPressed(_ sender: Any) {
        hidePasswordHelper()
    }
    
    private func hidePasswordHelper() {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        cPasswordTextField.isSecureTextEntry = !cPasswordTextField.isSecureTextEntry
        if(passwordTextField.isSecureTextEntry) {
            hidePasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            cHidePasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            hidePasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
            cHidePasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    @IBAction func segmentChanged(_ sender: Any) {
        switch segCtrl.selectedSegmentIndex {
        case 0:
            cPasswordLabel.isHidden = true
            cPasswordTextField.isHidden = true
            cHidePasswordButton.isHidden = true
            hidePasswordButton.isHidden = false
            passwordTextField.isSecureTextEntry = true
            hidePasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            loginButton.setTitle("Sign In", for: .normal)
        case 1:
            cPasswordLabel.isHidden = false
            cPasswordTextField.isHidden = false
            cPasswordTextField.isSecureTextEntry = false
            passwordTextField.isSecureTextEntry = false
            hidePasswordButton.isHidden = true
            //cHidePasswordButton.isHidden = false
            loginButton.setTitle("Sign Up", for: .normal)
        default:
            print("error")
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        statusLabel.text = nil

        guard let email = usernameTextField.text,
              let password = passwordTextField.text,
              email.count > 5,
              password.count > 5
        else {
            statusLabel.text = "Please try again"
          return
        }

        if(cPasswordLabel.isHidden) {
            Auth.auth().signIn(withEmail: email, password: password) {
              user, error in
                if let _ = error, user == nil {
                self.statusLabel.text = "Sign in failed"
              }else {
                // store login info
                self.login = LoginModel(loginID: email, password: password)
                self.login!.storeProfile()
                NotificationCenter.default.addObserver(self, selector: #selector(self.segueToHome), name: self.userNotification, object: nil)
                self.login?.getInfoFromFirebase()
                self.displaySignInPendingAlert()
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
            self.login = LoginModel(loginID: email, password: password)
            self.performSegue(withIdentifier: segueID1, sender: nil)
        }
    }
    
    // call this when our observer has been notified that loading user is done
    @objc func segueToHome() {
        self.user = self.login?.getUserModel()
        pending.dismiss(animated: true, completion: {
                            self.performSegue(withIdentifier: self.segueID0, sender: nil)})
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == segueID1,
           let cProfileVC = segue.destination as? CreateProfileViewController {
            cProfileVC.login = login
            }
        if segue.identifier! == segueID0,
           let destinationVC = segue.destination as? UINavigationController,
           let homeVC = destinationVC.viewControllers[0] as? HomeViewController {
            homeVC.user = self.user
            }
            
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
        
}
