//
//  SearchViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 12/5/20.
//

import UIKit
import MapKit
import Firebase


class ResourcesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var eventResultsTable: UITableView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var searchToggle: UISegmentedControl!
    let eventsRef = Firestore.firestore().collection("events")
    let cellID = "cell"
    var citiesReturned: [String] = []
    var statesReturned: [String] = []
    var urlsReturned: [String] = []
    let myGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventResultsTable.delegate = self
        eventResultsTable.dataSource = self
        FirebaseApp.configure()

        let db = Firestore.firestore()
        
        // Create a reference to the cities collection
        let citiesRef = db.collection("resources")
        
        enterButton.layer.cornerRadius = 4
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    

    @IBAction func enter(_ sender: Any) {
        myGroup.enter()
        citiesReturned = []
        statesReturned = []
        urlsReturned = []
        if(searchToggle.selectedSegmentIndex == 0) {
            //search for city
            // Create a query against the collection.
            let query = citiesRef.whereField("city", isEqualTo: search.text?.lowercased())
                .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        citiesReturned.append(document["city"])
                        statesReturned.append(document["state"])
                        urlsReturned.append(document["url"])
                    }
                }
        }
            myGroup.leave()
        }
        else {
            //search for state
            for annotation in delegate.mapView.annotations {
                let model = annotation as? EventAnnotation
                if model?.address != nil {
                    if(model!.address!.contains(search.text!)) {
                        print("HERE")
                        citiesReturned.append(model!.title!)
                        statesReturned.append(model!.coordinate)
                    }
                }
            }
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            self.eventResultsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let cell = eventResultsTable.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath)
        
        cell.textLabel?.text = citiesReturned[indexPath.row] + ", " + statesReturned[indexPath.row]
        //cell.textLabel?.text = eventNamesReturned[indexPath.row]
        //searchResult
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let homeVC = delegate as! FocusMap
        let coords = annotations[indexPath.row].coordinate
        homeVC.focusMap(eventCoords: coords)
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        myGroup.enter()
        annotations = []
        if(searchToggle.selectedSegmentIndex == 0) {
            //search for name
            for annotation in delegate.mapView.annotations {
                let model = annotation as? EventAnnotation
                if model?.title != nil {
                    //print("|",search.text!,"|",model!.title!)
                    if(model!.title!.contains(search.text!)) {
                        //print("HERE")
                        annotations.append(model!)
                        //eventNamesReturned.append(model!.title!)
                        //eventCoordsReturned.append(model!.coordinate)
                    }
                }
            }
            myGroup.leave()
        }
        else {
            //search for address
            for annotation in delegate.mapView.annotations {
                let model = annotation as? EventAnnotation
                if model?.address != nil {
                    if(model!.address!.contains(search.text!)) {
                        //print("HERE")
                        annotations.append(model!)
                        //eventNamesReturned.append(model!.title!)
                        //eventCoordsReturned.append(model!.coordinate)
                    }
                }
            }
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            self.annotations.sort(by: { (a1, a2) -> Bool in
                if let s1 = a1.title {
                    if let s2 = a2.title {
                        return s1 < s2
                    }
                }
                return false
            })
            self.eventResultsTable.reloadData()
        }
        
    }
}

