//
//  SearchViewController.swift
//  Mobilize
//
//  Created by Joseph Graham on 10/28/20.
//

import UIKit
import MapKit
import Firebase


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventResultsTable: UITableView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var searchToggle: UISegmentedControl!
    let eventsRef = Firestore.firestore().collection("events")
    let cellID = "eventCell"
    var eventNamesReturned: [String] = []
    var eventIDsReturned: [String] = []
    let myGroup = DispatchGroup()
    var homeViewController: HomeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventResultsTable.delegate = self
        eventResultsTable.dataSource = self
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func enter(_ sender: Any) {
        eventNamesReturned = []
        eventIDsReturned = []
        myGroup.enter()
        homeViewController.mapView.removeAnnotation(<#T##annotation: MKAnnotation##MKAnnotation#>)
        if(searchToggle.selectedSegmentIndex == 0) {
            eventsRef.whereField("name", isEqualTo: search.text!).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.eventNamesReturned.append(document.get("name") as! String)
                        self.eventIDsReturned.append(document.get("eventID") as! String)
                        print("\(document.documentID) => \(document.data())")
                    }
                    self.myGroup.leave()
                }
            }
        }
        else {
            eventsRef.whereField("address", isEqualTo: search.text!).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.eventNamesReturned.append(document.get("name") as! String)
                        self.eventIDsReturned.append(document.get("eventID") as! String)
                        print("\(document.documentID) => \(document.data())")
                    }
                    self.myGroup.leave()
                }
            }
        }
        myGroup.notify(queue: .main) {
            self.eventResultsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventNamesReturned.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let cell = eventResultsTable.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath)
        
        cell.textLabel?.text = eventNamesReturned[indexPath.row]
        //searchResult
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myGroup.enter()
        eventsRef.whereField("eventID", isEqualTo: eventIDsReturned[indexPath.row]).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let nav = self.navigationController
                    let homeVC = nav!.viewControllers[0] as! HomeViewController
                    let docData = document.get("coordinates") as! NSDictionary
                    let long = docData.value(forKey: "longitude") as! Double
                    let lat  = docData.value(forKey: "latitude") as! Double
                    let coordinates = CLLocationCoordinate2DMake(lat, long)
                    let region = (homeVC.mapView.regionThatFits(MKCoordinateRegion(center: coordinates as! CLLocationCoordinate2D, latitudinalMeters: 0, longitudinalMeters: 1500)))
                    homeVC.mapView.setRegion(region, animated: true)
                        
                    self.navigationController?.popToRootViewController(animated: true)
                }
                self.myGroup.leave()
            }
        }
    }
    
}
