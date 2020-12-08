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
    var delegate : HomeViewController!
    var annotations : [EventAnnotation] = []
    var eventNamesReturned: [String] = []
    var eventCoordsReturned: [CLLocationCoordinate2D] = []
    let myGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventResultsTable.delegate = self
        eventResultsTable.dataSource = self
        search.delegate = self
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
        return annotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = eventResultsTable.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath)
        
        let pin = annotations[indexPath.row]
    
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = pin.title
        cell.detailTextLabel?.text = "\(pin.address!)\n\(pin.subtitle!)"
        let activismType = pin.activismType
        let color = EventModel.returnColor(activismType: activismType!)
        let image = UIImage(systemName: "circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(color)
        cell.imageView?.image = image
        
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
                    if(model!.title!.contains(search.text!)) {
                        annotations.append(model!)
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
                        annotations.append(model!)
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
