//
//  LoginModel.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/12/20.
//

import Foundation
import CoreData
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class LoginModel {
    
    var loginID:String?
    var password:String?
    private var userModel:UserModel?
    
    let db = Firestore.firestore()
        
    // initialize login model with username and password
    init(loginID:String, password:String) {
        self.loginID = loginID
        self.password = password
        
    }
    
    // initialize login model with current user's uid
    init(userID:String) {
        self.loginID = nil
        self.password = nil
    }
    
    // helper method that saves login information into core data
    func storeProfile() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let profileToStore = NSEntityDescription.insertNewObject(forEntityName: "ProfileEntity", into:context)
        // set the attribute variables
        profileToStore.setValue(loginID, forKey: "uid")
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
    
    func getInfoFromFirebase() {
        let userID = Auth.auth().currentUser?.uid
        let docRef = self.db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                let firstName = dataDescription!["firstName"] as! String
                let lastName = dataDescription!["lastName"] as! String
                let org = dataDescription!["organization"] as! String
                let bio = dataDescription!["bio"] as! String
                let urlDatabase = dataDescription!["profileImageURL"] as! String
                let url = URL(string: urlDatabase)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print("error retrieving image")
                        return
                    }
                    DispatchQueue.main.async {
                        self.userModel = UserModel(uid: userID!, first: firstName, last: lastName, organization: org, bio: bio, profilePicture: UIImage(data: data!)!, eventsRSVPd: [String](), eventsCreated: [String](), eventsLiked: [String](), loginInfo: self)
                        let name = Notification.Name(rawValue: "userModelNotificationKey")
                        NotificationCenter.default.post(name: name, object: nil)
                    }
                }).resume()
            } else {
                print("Document does not exist")
                return
            }
        }
    }
    
    // MUST call getInfoFromFirebase first, use observers
    func getUserModel() -> UserModel {
        return userModel!
    }
    
}
