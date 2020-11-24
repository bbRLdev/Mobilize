//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/15/20.
//
import UIKit
import MapKit
import SideMenu
import CoreLocation
import Firebase
import CoreData

protocol GetFilters {
    func getFilters(actFilters: [String], evtFilters: [String], radius: Float)
}

class HomeViewController: UIViewController, GetFilters {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var sideMenu: SideMenuNavigationController?
    
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    
    var eventFilters: [String] = []
    var activismFilters: [String] = []
    var searchRadius: Float = 50.0
    
    var user:UserModel?
    var login:LoginModel?
    
    let userNotification = Notification.Name(rawValue: "userModelNotificationKey")
    
    var pending = UIAlertController(title: "Signing in\n\n", message: nil, preferredStyle: .alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSideMenu()
        checkLocationServices()
        loadPins()
        setMapDelegate()
        if(user == nil) {
            // need to try loading in user data
            loadInUserData()
        }
    }
    
    func loadInUserData() {
        login = LoginModel(userID: Auth.auth().currentUser!.uid)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissLoading), name: self.userNotification, object: nil)
        self.displaySignInPendingAlert()
        login!.getInfoFromFirebase()
        
    }
    
    // called if we need to load in user data first
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
    
    // called after observer is notified that user data is loaded
    @objc func dismissLoading() {
        user = login?.getUserModel()
        pending.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FilterSegueId",
           let nextVC = segue.destination as? FilterViewController {
            nextVC.delegate = self
            nextVC.radius = searchRadius
            nextVC.initActivismButtons = activismFilters
            nextVC.initEventButtons = eventFilters
        }
    }
    
    @IBAction func sideNavButtonPressed(_ sender: Any) {
        present(sideMenu!, animated: true)
    }
    
    @IBAction func createEvent(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateEventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Confirm") as! ConfirmViewController
        self.show(vc, sender: self)
    }
    
    // Protocol method
    func getFilters(actFilters: [String], evtFilters: [String], radius: Float) {
        activismFilters = actFilters
        eventFilters = evtFilters
        searchRadius = radius

    }
    
    func setUpSideMenu() {
        sideMenu = SideMenuNavigationController(rootViewController: SideMenuListController())
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu        
    }
    
    private func addPin(diff :DocumentChange){
        let dataDescription = diff.document.data()
        if(dataDescription["coordinates"] == nil){
            return
        }
        let coordDict = dataDescription["coordinates"] as? NSDictionary
        let eventName = dataDescription["name"] as? String
        let ownerID = dataDescription["owner"] as? String
        let ownerOrg = dataDescription["orgName"] as? String
        let latitude:Double = coordDict?.value(forKey: "latitude") as! Double
        let longitude:Double = coordDict?.value(forKey: "longitude") as! Double
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        
        let annotation = AnnotationModel(eid: diff.document.documentID)
        annotation.title = eventName
        annotation.subtitle = ownerOrg
        //print(ownerOrg!)
        annotation.coordinate = coordinates
        
        self.mapView.addAnnotation(annotation)

    }
    private func removePin(diff :DocumentChange){
        let eventID = diff.document.documentID
        for annotation in self.mapView.annotations {
            if let model = annotation as? AnnotationModel,
               model.eventID == eventID{
                self.mapView.removeAnnotation(model)
            }
        }
    }
    func loadPins(){
        db.collection("events")
            .addSnapshotListener { querySnapshot, error in
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        //print("New event: \(diff.document.data())")
                        self.addPin(diff: diff)
                    }
                    else if (diff.type == .modified) {
                        //print("Modified event: \(diff.document.data())")
                        self.removePin(diff: diff)
                        self.addPin(diff: diff)
                    }
                    else if (diff.type == .removed) {
                        //print("Removed event: \(diff.document.data())")
                        self.removePin(diff: diff)
                    }
                }
            }
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        print("got to check location services")
        if CLLocationManager.locationServicesEnabled() {
            // set up location manager
            setUpLocationManager()
            checkLocationAuthorization()
        } else {
            // show alert letting user knowing they need to turn location services on
        }
        
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            // Do map stuff
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // show an alert saying location is restricted (parent controls, etc.)
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("Error in checking location authorization")
        }
    }
    
}

extension HomeViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    func setMapDelegate(){
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? AnnotationModel {
            print(annotation.eventID)
            
            let controller = UIAlertController(title: "Options for",
                                               message: annotation.title,
                                                preferredStyle: .actionSheet)
            
            let zoomAction = UIAlertAction(title: "Focus Map",
                                            style: .default,
                                            handler: {
                                                [self](action) in
                                                self.mapView.deselectAnnotation(annotation, animated: true)
                                                let region = self.mapView.regionThatFits(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 0, longitudinalMeters: 1000))
                                                self.mapView.setRegion(region, animated: true)})
            
            controller.addAction(zoomAction)
            
            let detailsAction = UIAlertAction(title: "Event Details",
                                            style: .default,
                                            handler: {
                                                [self](action) in
                                                self.mapView.deselectAnnotation(annotation, animated: true)
                                                let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
                                                let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
                                                
                                                vc.eventID = annotation.eventID
                                                self.show(vc, sender: self)})
            
            controller.addAction(detailsAction)
            
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                action in
                self.mapView.deselectAnnotation(annotation, animated: true)
            }))
            
            present(controller, animated: true, completion: nil)
            
        }
    }
    // update the location on map when user moves around
    // (leave out? annoying b/c stops user from moving map around)

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {
//            return
//        }
//        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
    }
    
    // called when user changes their location authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
