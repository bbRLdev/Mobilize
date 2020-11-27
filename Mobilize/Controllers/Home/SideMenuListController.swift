//
//  SideMenuListController.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/19/20.
//

import Foundation
import SideMenu
import UIKit
import FirebaseAuth
import CoreData
import FirebaseFirestore

class SideMenuListController: UIViewController {
    
    var tableView = UITableView()
    var imageView: UIImageView!
    var name: UILabel!
    var user: UserModel?
        
    var items = [NavLinks.profile.rawValue, NavLinks.events.rawValue, NavLinks.settings.rawValue, NavLinks.logout.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUpImageView()
        setUpLabel()
        setupTableView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        //loadProfileInfo()
        //loadUserModelInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProfileInfo()
        //loadUserModelInfo()
    }
    
    // load in from user state
    func loadUserModelInfo() {
        self.name.text = (user?.first)! + " " + (user?.last)!
        self.imageView.image = user?.profilePicture
    }
    
    // load in from firebase
    func loadProfileInfo() {
        let userID = Auth.auth().currentUser?.uid
        let docRef = Firestore.firestore().collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let firstName = dataDescription!["firstName"] as! String
                let lastName = dataDescription!["lastName"] as! String
                
                self.name.text = firstName + " " + lastName
                let urlDatabase = dataDescription!["profileImageURL"] as! String
                let url = URL(string: urlDatabase)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print("error retrieving image")
                        return
                    }
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data!)
                    }
                }).resume()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func setUpImageView() {
        imageView = UIImageView(image: UIImage(named: "defaultProfile"))
        imageView.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 2
    }
    
    func setUpLabel() {
        name = UILabel(frame: CGRect(x: 0, y: 0, width: 250.0, height: 100.0))
        name.text = "Firstname Lastname"
        name.backgroundColor = UIColor.white
        view.addSubview(name)
        name.translatesAutoresizingMaskIntoConstraints = false
        name.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        name.heightAnchor.constraint(equalToConstant: 50).isActive = true
        name.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func handleLogout() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ProfileEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try
                context.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }

        do {
            try Auth.auth().signOut()
            let storyboard: UIStoryboard = UIStoryboard(name: "LoginStory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            
            self.show(vc, sender: self)
        } catch let error {
            print("Error: ", error.localizedDescription)
        }
    }
    
    enum NavLinks: String, CaseIterable {
        case profile = "Profile", events = "Your Events", settings = "Settings", logout = "Log Out"
    }
}

extension SideMenuListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        
        if(cell.textLabel?.text == "Profile") {
            cell.imageView?.image = resizeImageWithAspect(image: UIImage(systemName: "person")!, scaledToMaxWidth: 25, maxHeight: 25)
        }
        
        if(cell.textLabel?.text == "Your Events") {
            cell.imageView?.image = resizeImageWithAspect(image: UIImage(systemName: "list.dash")!, scaledToMaxWidth: 25, maxHeight: 25)
        }
        
        if(cell.textLabel?.text == "Settings") {
            cell.imageView?.image = resizeImageWithAspect(image: UIImage(systemName: "gearshape")!, scaledToMaxWidth: 25, maxHeight: 25)
        }
        
        if(cell.textLabel?.text == "Log Out") {
            cell.textLabel?.textColor = UIColor.red
            cell.imageView?.image = resizeImageWithAspect(image: UIImage(systemName: "arrow.right")!, scaledToMaxWidth: 25, maxHeight: 25)?.withTintColor(UIColor.red)
        }
        
        return cell
    }
    
    func resizeImageWithAspect(image: UIImage, scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Profile") as! SettingsProfileViewController
            vc.profile = user
            self.show(vc, sender: self)
        } else if (indexPath.row == 1) {
            let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileEvents") as! ProfileEventsViewController
            let userID = Auth.auth().currentUser?.uid
            vc.uid = userID
            self.show(vc, sender: self)
        } else if (indexPath.row == 2) {
            let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SettingsView") as! SettingsViewController
            vc.user = user
            self.show(vc, sender: self)
        }
        else if (indexPath.row == 3) {
            let controller = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title:"Yes", style: .destructive, handler: {_ in self.handleLogout()}))
            controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
        }
    }
}
