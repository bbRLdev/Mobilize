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
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventResultsTable.delegate = self
        eventResultsTable.dataSource = self
        
        // Create a reference to the cities collection
        
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
        let citiesRef = db.collection("resources")
        if(searchToggle.selectedSegmentIndex == 0) {
            // search for city
            // Create a query against the collection.\
            let query = citiesRef.whereField("city", isEqualTo: search.text!.lowercased())
                .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print(document.get("city") as! String)
                        self.citiesReturned.append(document.get("city") as! String)
                        self.statesReturned.append(document.get("state") as! String)
                        self.urlsReturned.append(document.get("url") as! String)
                        print("1",self.citiesReturned)
                    }
                    self.myGroup.leave()
                }
                }
        }else {
            //search for state
            let query = citiesRef.whereField("state", isEqualTo: search.text!.lowercased())
                .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.citiesReturned.append(document.get("city") as! String)
                        self.statesReturned.append(document.get("state") as! String)
                        self.urlsReturned.append(document.get("url") as! String)
                    }
                    self.myGroup.leave()
                }
                }
        }
        myGroup.notify(queue: .main) {
            print(self.citiesReturned)
            self.eventResultsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchToggle.selectedSegmentIndex == 0) {
            return citiesReturned.count
        }
        return statesReturned.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventResultsTable.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath)
        let city = citiesReturned[indexPath.row].prefix(1).capitalized + citiesReturned[indexPath.row].suffix(citiesReturned[indexPath.row].count-1)
        let state = statesReturned[indexPath.row].prefix(1).capitalized + statesReturned[indexPath.row].suffix(statesReturned[indexPath.row].count-1)
        cell.textLabel?.text = city + ", " + state
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: urlsReturned[indexPath.row]) {
            UIApplication.shared.open(url)
        }
    }
}
