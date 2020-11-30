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
    
    @IBOutlet weak var trackLocationButton: UIButton!
    
    var sideMenu: SideMenuNavigationController?
    
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    
    var eventFilters: [String] = []
    var activismFilters: [String] = []
    var searchRadius: Float = 0.0
    
    var user:UserModel?
    var login:LoginModel?
    
    var eventListener:ListenerRegistration?
    var selectedPin:MKAnnotation?
    
    var filteredAnnotations : [EventAnnotation] = []

    var trackLocation = false
    
    //var coordToPin:[CLLocationCoordinate2D:[AnnotationModel]] = [:]
    
    let userNotification = Notification.Name(rawValue: "userModelNotificationKey")
    
    var pending = UIAlertController(title: "Signing in\n\n", message: nil, preferredStyle: .alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSideMenu()
        checkLocationServices()
        loadPins()
        setMapDelegate()
        
        trackLocationButton.isSelected = trackLocation
        
        if(user == nil) {
            // need to try loading in user data
            loadInUserData()
        }
        mapView.register(LocationDataMapClusterView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        mapView.register(EventAnnotationView.self, forAnnotationViewWithReuseIdentifier: "event")
        print(mapView.selectedAnnotations)
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
        user = login!.getUserModel()
        let menuVC = SideMenuManager.default.leftMenuNavigationController?.viewControllers.first as! SideMenuListController
        menuVC.user = user
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
//        if let sideMenuVC = segue.destination as? SideMenuListController {
//            print("GOT HERE")
//            sideMenuVC.user = user!
//        }
//        else if segue.identifier == "ListEventsSegue"{
//            let nextVC = segue.destination as? FilterViewController {
//             nextVC.delegate = self
//             nextVC.radius = searchRadius
//             nextVC.initActivismButtons = activismFilters
//             nextVC.initEventButtons = eventFilters
//         }
//        }
    }
    
    @IBAction func sideNavButtonPressed(_ sender: Any) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true)
    }
    
    
    @IBAction func trackLocationButtonPressed(_ sender: Any) {
        trackLocation = !trackLocation
        trackLocationButton.isSelected = trackLocation
    }
    
    
    @IBAction func changeMapButtonPressed(_ sender: Any) {
        switch mapView.mapType {
        case .standard:
            mapView.mapType = MKMapType.satellite
        case .satellite:
            mapView.mapType = MKMapType.hybrid
        case .hybrid:
            mapView.mapType = MKMapType.standard
        default:
            print("This shouldn't happen")
        }
    }
    
    @IBAction func createEvent(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateEventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Confirm") as! ConfirmViewController
        self.show(vc, sender: self)
    }
    
    // Protocol method
    func getFilters(actFilters: [String], evtFilters: [String], radius: Float) {
        if filteredAnnotations.count != 0 {
            mapView.addAnnotations(filteredAnnotations)
            filteredAnnotations = []
        }
        activismFilters = actFilters
        eventFilters = evtFilters
        searchRadius = radius
        
        let currentAnnotations = mapView.annotations
        for annotation in currentAnnotations {
            if let eventAnnotation = annotation as? EventAnnotation {
                var keep: Bool = true
                let eventActivismFilter = eventAnnotation.activismType
                let eventEventFilter = eventAnnotation.eventType
                if searchRadius != 0 {
                    if let currentLocation = locationManager.location?.coordinate {
                        let locationPoint = MKMapPoint(currentLocation)
                        let eventMapPoint = MKMapPoint(eventAnnotation.coordinate)
                        let distance = locationPoint.distance(to: eventMapPoint)
                        let distanceMiles = distance * 0.000621371192
                        keep = keepAnnotationEvent(evtFilters: eventFilters, filter: eventEventFilter!) && distanceMiles.isLessThanOrEqualTo(Double(searchRadius)) && keepAnnotationActivism(actFilters: actFilters, filter: eventActivismFilter!)
                    }
                } else {
                    keep = keepAnnotationEvent(evtFilters: eventFilters, filter: eventEventFilter!) && keepAnnotationActivism(actFilters: actFilters, filter: eventActivismFilter!)
                }
                if !keep {
                    filteredAnnotations.append(eventAnnotation)
                }
            }
        }
        mapView.removeAnnotations(filteredAnnotations)
    }
    
    // Check if filter is equal to one of the filters in act filter
    func keepAnnotationActivism(actFilters: [String], filter: String) -> Bool {
        if actFilters.count == 0 {
            return true
        }
        for activismFilter in actFilters {
            if filter == activismFilter {
                return true
            }
        }
        // filter not equal to anything in act filter
        return false
    }
    
    func keepAnnotationEvent(evtFilters: [String], filter: String) -> Bool {
        if evtFilters.count == 0 {
            return true
        }
        for eventFilter in evtFilters {
            if filter == eventFilter {
                return true
            }
        }
        return false
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
        let date = dataDescription["date"] as! Timestamp
        let ownerID = dataDescription["owner"] as? String
        let ownerOrg = dataDescription["orgName"] as? String
        let latitude:Double = coordDict?.value(forKey: "latitude") as! Double
        let longitude:Double = coordDict?.value(forKey: "longitude") as! Double
        let activismType = dataDescription["activismTypeFilter"] as? String
        let eventType = dataDescription["eventTypeFilter"] as? String
        let likes = dataDescription["numLikes"] as! Int
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        
        //let annotation = AnnotationModel(eid: diff.document.documentID)
        let annotation = EventAnnotation(eid: diff.document.documentID, numLikes: likes)
        
        
        let dFormatter = DateFormatter()
        dFormatter.dateStyle = .medium
        
        let dateString = dFormatter.string(from: date.dateValue() )
        
        annotation.title = eventName
        annotation.subtitle = "Date: \(dateString)\nOrganization: \(ownerOrg!)\nActivism Type: \(activismType ?? "None")\nEvent Type: \(eventType ?? "None")"
        annotation.activismType = activismType
        annotation.eventType = eventType
        //print(ownerOrg!)
        annotation.coordinate = coordinates
        
        self.mapView.addAnnotation(annotation)
    }
    
    private func removePin(diff :DocumentChange){
        let eventID = diff.document.documentID
        for annotation in self.mapView.annotations {
            if let model = annotation as? EventAnnotation,
               model.eventID == eventID{
                self.mapView.removeAnnotation(model)
            }
        }
    }
    
    func loadPins(){
        eventListener = db.collection("events")
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

    @objc func infoClicked(){
        if let annotation = selectedPin as? EventAnnotation{
            print(annotation.eventID)
            let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController

            vc.eventID = annotation.eventID
            self.show(vc, sender: self)

        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        switch annotation {
    
        case is EventAnnotation:
            let view: EventAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "event") as? EventAnnotationView


            let eventAnnotation = annotation as! EventAnnotation
            let activismType = eventAnnotation.activismType!
            let annotationColor = EventModel.returnColor(activismType: activismType)
        
            let image = UIImage(systemName: "circle.fill")?.withTintColor(annotationColor)
            
            let width = min(20 + 0.5 * Double(eventAnnotation.likes).squareRoot(), 100)
            let height = min(20 + 0.5 * Double(eventAnnotation.likes).squareRoot(), 100)
            
            let resizedSize = CGSize(width: width, height: height)

            UIGraphicsBeginImageContext(resizedSize)
            image?.draw(in: CGRect(origin: .zero, size: resizedSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            view?.image = resizedImage
            view?.clusteringIdentifier = "cluster"
            view?.canShowCallout = true
            view?.annotation = eventAnnotation

        case is AnnotationModel:    
            
            let btn = UIButton(type: .detailDisclosure)
            
            let annotationTitle = UILabel()
            let annotationSubtitle = UILabel()
            annotationTitle.font = UIFont.boldSystemFont(ofSize: 12)
            annotationSubtitle.font = UIFont.systemFont(ofSize: 11)
            
            annotationSubtitle.numberOfLines = 0
            annotationTitle.text = annotation.title as? String
            annotationSubtitle.text = annotation.subtitle as? String
            
            btn.addTarget(self, action:#selector(self.infoClicked), for: .touchUpInside)
            view?.rightCalloutAccessoryView = btn
            view?.leftCalloutAccessoryView = annotationTitle
            view?.detailCalloutAccessoryView = annotationSubtitle
            
            return view
        
        case is MKClusterAnnotation:
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation)
            return view
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        switch view.annotation {
        
        case is EventAnnotation:
            selectedPin = view.annotation
        case is MKClusterAnnotation:
            
            if let annotation = view.annotation as? MKClusterAnnotation{
                let controller = UIAlertController(title: "Options for",
                                                   message: "annotation cluster",
                                                    preferredStyle: .actionSheet)

                let zoomAction = UIAlertAction(title: "Focus Map",
                                                style: .default,
                                                handler: {
                                                    [self](action) in
                                                    self.mapView.deselectAnnotation(annotation, animated: true)
//                                                    print(self.mapView.region.span.longitudeDelta.magnitude)
                                                    
                                                    let region = self.mapView.regionThatFits(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 0, longitudinalMeters: self.mapView.region.span.longitudeDelta.magnitude.squareRoot()*regionInMeters)) // may break near the poles
                                                    self.mapView.setRegion(region, animated: true)})

                controller.addAction(zoomAction)

                let detailsAction = UIAlertAction(title: "List All Events",
                                                style: .default,
                                                handler: {
                                                    [self](action) in

                                                    let storyboard: UIStoryboard = UIStoryboard(name: "ClusterPin", bundle: nil)
                                                    let vc = storyboard.instantiateViewController(withIdentifier: "PinTable") as! ClusterPinViewController
                                                    
                                                    vc.pins = annotation.memberAnnotations
                                                    self.mapView.deselectAnnotation(annotation, animated: true)
                                                    self.show(vc, sender: self)
                                                    //self.present(vc, animated: true, completion: nil)
                                                    
                                                    })

                controller.addAction(detailsAction)

                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    action in
                    self.mapView.deselectAnnotation(annotation, animated: true)
                }))

                present(controller, animated: true, completion: nil)
            }

        default:
            return
        }

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(trackLocation){
            guard let location = locations.last else {
                return
            }
            
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 0, longitudinalMeters: 1500)
            mapView.setRegion(region, animated: true)
        }

    }
    
    // called when user changes their location authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

