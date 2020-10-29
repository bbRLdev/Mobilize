//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/15/20.
//
import UIKit
import CoreData

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let options = ["Edit Profile", "Notifications"]
    let cellTag = "cell"
    @IBOutlet var Options: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            print("here")
            performSegue(withIdentifier: "edit", sender: self)
        }
        if(indexPath.row == 1) {
            performSegue(withIdentifier: "notifications", sender: self)
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title:"Yes", style: .destructive, handler: {_ in self.handleLogout()}))
        controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    // helper method that will delete log in data
    private func handleLogout() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileEntity")
        var fetchedResults: [NSManagedObject]
        do {
            print("GOT HERE")
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
        // show login screen
        let storyboard = UIStoryboard(name: "LoginStory", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        show(loginViewController, sender: self)

    }
}
