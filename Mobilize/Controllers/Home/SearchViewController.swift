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

    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var eventResultsTable: UITableView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var searchToggle: UISegmentedControl!
    let eventsRef = Firestore.firestore().collection("events")
    let cellID = "eventCell"
    var delegate : HomeViewController!
    var annotations : [EventAnnotation] = []
    var eventNamesReturned: [String] = []
    var eventCoordsReturned: [CLLocationCoordinate2D] = []
    let myGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventResultsTable.delegate = self
        eventResultsTable.dataSource = self
        
        enterButton.layer.cornerRadius = 4
    }
    
    // code to enable tapping on the background to remove software keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func enter(_ sender: Any) {
        myGroup.enter()
        eventNamesReturned = []
        eventCoordsReturned = []
        if(searchToggle.selectedSegmentIndex == 0) {
            //search for name
            for annotation in delegate.mapView.annotations {
                let model = annotation as? EventAnnotation
                if model?.title != nil {
                    print("|",search.text!,"|",model!.title!)
                    if(model!.title!.contains(search.text!)) {
                        print("HERE")
                        eventNamesReturned.append(model!.title!)
                        eventCoordsReturned.append(model!.coordinate)
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
                        print("HERE")
                        eventNamesReturned.append(model!.title!)
                        eventCoordsReturned.append(model!.coordinate)
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
        let homeVC = delegate as! FocusMap
        homeVC.focusMap(eventCoords: eventCoordsReturned[indexPath.row])
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
}
