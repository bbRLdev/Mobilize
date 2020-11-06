//
//  EventInfoViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/31/20.
//

import UIKit
import MapKit
import Contacts
import FirebaseAuth

class EventInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate, UITextViewDelegate {

    
    let auth = FirebaseAuth.Auth.auth()
    let textCellIdentifier = "AddressCell"
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    var coordinates: CLLocationCoordinate2D? = nil
    
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var organizationNameField: UITextField!
    @IBOutlet weak var eventAddressField: UITextField!
    @IBOutlet weak var eventDescriptionField: UITextView!
    let segueId = "AddMediaSegueId"
    var event: EventModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        eventDescriptionField.layer.borderWidth = 0.5
        eventDescriptionField.layer.cornerRadius = 5.0;
        eventDescriptionField.clipsToBounds = true;
        eventDescriptionField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        // Do any additional setup after loading the view.
        
        searchCompleter.delegate = self
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        populateFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchResultsTableView.isHidden = true
    }
    
    @IBAction func onNextButtonPressed(_ sender: Any) {
        
        if(eventNameField.text == "" || organizationNameField.text == "" || coordinates == nil){
            
            var msg = "please enter event information"
            if(coordinates == nil){
                msg = "select an address from the search results"
            }
            let controller = UIAlertController(title: "Missing fields",
                                               message: msg,
                                               preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: nil))
            
            present(controller, animated: true, completion: nil)
            
            return
        }
        guard let eventName = eventNameField.text,
               let orgName = organizationNameField.text,
               let eventAddress = eventAddressField.text,
               let eventDescription = eventAddressField.text,
               let eventCoordinates = coordinates,
               let uid = auth.currentUser?.uid
        else {
            return
        }
        event = EventModel(name: eventName, desc: eventDescription, loc: eventAddress, org: orgName, coord: eventCoordinates, owner: uid)
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId,
           let nextVC = segue.destination as? AddMediaViewController {
            nextVC.event = event
        }
    }

    @IBAction func editBegin(_ sender: Any) {
        searchResultsTableView.isHidden = false
        coordinates = nil
    }
    
    @IBAction func editEnd(_ sender: Any) {
        searchResultsTableView.isHidden = true
        searchCompleter.queryFragment = ""
    }
    
    @IBAction func editChanged(_ sender: Any) {
        searchCompleter.queryFragment = eventAddressField.text!
    }
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        //searchCompleter.queryFragment = eventAddressField.text!
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let searchResult = searchResults[indexPath.row]
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        //searchResult
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchResultsTableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            //get coordinate for map pin
            let coordinate = response?.mapItems[0].placemark.coordinate
            
            self.coordinates = coordinate
            print(String(describing: coordinate))
            
            let addresses = response?.mapItems.compactMap { item -> String? in
                return item.placemark.postalAddress.flatMap {
                    formatter.string(from: $0).replacingOccurrences(of: "\n", with: ", ")
                }
            }
            self.eventAddressField.text = addresses?[0]

        }
        
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Start Editing The Text Field
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: -250, up: true)
    }
    
    // Finish Editing The Text Field
    func textViewDidEndEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: -250, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextView(_ textField: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func populateFields() {
        // check if the event has a UID, if so, can populate fields for edit
        if(event != nil) {
            eventNameField.text = event.eventName
            organizationNameField.text = event.organization
            eventAddressField.text = event.location
            eventDescriptionField.text = event.description
        }
    }


}
