//
//  AppDelegate.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/13/20.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let userDefault = UserDefaults.standard
    let launchedBefore = UserDefaults.standard.bool(forKey: "usersingedin")
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        configureInitialViewController()
        return true
    }
    
    private func configureInitialViewController() {
        let loggedIn = checkIfLoggedIn()
        window = UIWindow()
        let initialViewController: UIViewController
        if(loggedIn) {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
            initialViewController = mainViewController
        }else {
            let storyboard = UIStoryboard(name: "LoginStory", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
            initialViewController = loginViewController
        }
        window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    // checks if there is already user info saved in core data
    private func checkIfLoggedIn() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileEntity")
        var fetchedResults: [NSManagedObject]? = nil
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
        
        // read in fetched results
        if(!fetchedResults!.isEmpty) {
            let profileEntity = fetchedResults![0]
            guard let uid = profileEntity.value(forKey:"uid") as? String,
                  let password = profileEntity.value(forKey:"password") as? String
                else {
                    print("could not find any user data")
                    return false
                }
            // try logging in
            Auth.auth().signIn(withEmail: uid, password: password) {
              user, error in
                if let _ = error, user == nil {
                    // couldn't sign in
                    self.userDefault.set(false, forKey: "usersignedin")
                    self.userDefault.synchronize()
                    print("error signing in")
                }else {
                    // signed in successfully
                    self.userDefault.set(true, forKey: "usersignedin")
                    self.userDefault.synchronize()
                    print("signed in successfully")
                }
            }
        }
        return userDefault.bool(forKey: "usersignedin")
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Mobilize")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

