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

protocol GetFilters {
    func getFilters(actFilters: [String], evtFilters: [String], radius: Float)
}

class HomeViewController: UIViewController, GetFilters {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var sideMenu: SideMenuNavigationController?
    
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    
    var eventFilters: [String] = []
    var activismFilters: [String] = []
    var searchRadius: Float = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSideMenu()
        checkLocationServices()
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
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: mapView)
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

extension HomeViewController: CLLocationManagerDelegate {
    
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

class SideMenuListController: UITableViewController {
    var items = [NavLinks.profile.rawValue, NavLinks.settings.rawValue, NavLinks.events.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Profile") as! SettingsProfileViewController
            self.show(vc, sender: self)
        } else if (indexPath.row == 1) {
            let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SettingsView") as! SettingsViewController
            self.show(vc, sender: self)
        } else if (indexPath.row == 2) {
            let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileEvents") as! ProfileEventsViewController
            self.show(vc, sender: self)
        }
    }
    
    enum NavLinks: String, CaseIterable {
        case profile = "Profile", settings = "Settings", events = "Your Events"
        
    }
}
