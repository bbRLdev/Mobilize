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
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let userDefault = UserDefaults.standard
    let launchedBefore = UserDefaults.standard.bool(forKey: "usersingedin")
    let locationManager = CLLocationManager()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        configureInitialViewController()
        // request notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { (success, error) in
        })
        UNUserNotificationCenter.current().delegate = self
        locationManager.requestWhenInUseAuthorization()
        return true
    }
    
    // This method is called when user clicked on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
        
        window?.rootViewController = mainViewController as! UINavigationController
        
        let rootViewController = self.window!.rootViewController as! UINavigationController

        let eventStoryboard : UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
        let vc : EventDetailsViewController = eventStoryboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
        
        let eventID = response.notification.request.identifier
        vc.eventID = eventID

        rootViewController.pushViewController(vc, animated: true)
    }
    
    // called if app is running in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
       willPresent notification: UNNotification,
       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(.banner)
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
        }else {
            print("no log in info")
            return false
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

