//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/15/20.
//
import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let options = ["Edit Profile", "Notifications"]
    let cellTag = "cell"
    var user: UserModel?
    
    @IBOutlet var Options: UITableView!
    @IBOutlet weak var button: UIButton!
    
    var pending = UIAlertController(title: "Deleting Profile\n\n", message: nil, preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        button.layer.cornerRadius = 4
        Options.delegate = self
        Options.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = options[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            performSegue(withIdentifier: "edit", sender: self)
        }
        if(indexPath.row == 1) {
            performSegue(withIdentifier: "notifications", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit",
           let editVC = segue.destination as? EditProfileViewController {
            editVC.profile = user
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let controller = UIAlertController(title: "Are you sure you want to delete your account?", message: "This action cannot be undone", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title:"Delete", style: .destructive, handler: {_ in self.handleDelete()}))
        controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    // helper method that will delete log in data
    private func handleDelete() {
        displaySignInPendingAlert()
        let user = Auth.auth().currentUser
        user?.delete { error in
          if let error = error {
            self.pending.dismiss(animated: true, completion: {
                let errorAlert = UIAlertController(title: "Error deleting profile", message: nil, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title:"OK", style: .default, handler: {_ in errorAlert.dismiss(animated: true, completion: nil)}))
                self.present(errorAlert, animated: true, completion: nil)
            })
            print(error)
          } else {
            Firestore.firestore().collection("users").document(user!.uid).delete() { err in
                if let err = err {
                    print("Deleted user but there was an error removing document: \(err)")
                } else {
                    // account deleted. Log out and show login screen
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileEntity")
                    var fetchedResults: [NSManagedObject]
                    do {
                        try fetchedResults = (context.fetch(request) as? [NSManagedObject])!
                        if(fetchedResults.count > 0) {
                            // clear all saved user data
                            for result:AnyObject in fetchedResults {
                                context.delete(result as! NSManagedObject)
                                print("\(result.value(forKey: "uid")!) has been deleted")
                            }
                        }
                        // commit the changes
                        try context.save()
                    } catch {
                        // if an error occurs
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                    self.pending.dismiss(animated: true, completion: {
                        // show login screen
                        let storyboard = UIStoryboard(name: "LoginStory", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
                        self.navigationController?.setNavigationBarHidden(true, animated: true)
                        self.show(loginViewController, sender: self)
                    })
                }
            }
          }
        }
    }
    
    func displaySignInPendingAlert() {
        
        //create an activity indicator
        let indicator = UIActivityIndicatorView(frame: pending.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        //add the activity indicator as a subview of the alert controller's view
        pending.view.addSubview(indicator)
        // required otherwise if there buttons in the UIAlertController you will not be able to press them
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()

        self.present(pending, animated: true, completion: nil)
    }
}
