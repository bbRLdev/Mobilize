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
import Firebase

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
    
    @IBOutlet weak var activismTypeFilterButton: UIButton!
    @IBOutlet weak var eventTypeFilterButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var eventDatePicker: UIDatePicker!

    let segueId = "AddMediaSegueId"
    
    // Post-Beta, we use this to keep track of values as we build the
    // new event
    var eventSoFar: [String : Any] = [:]
    var selectedActivismTypeFilter: String?
    var selectedEventTypeFilter: String?
    var selectedDate: Date?
    var dateComponents: DateComponents?
    // Post-Beta, this stays empty until the end if we are creating a new event.
    // if editing, it will not be nil. This does not matter until the end.
    var event: EventModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 4
        eventDescriptionField.layer.borderWidth = 0.5
        eventDescriptionField.layer.cornerRadius = 5.0;
        eventDescriptionField.clipsToBounds = true;
        eventDescriptionField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        
        searchCompleter.delegate = self
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self

        // Users cannot post an event in the same day. That would be
        // bad.
        // commenting for testing notifications
        eventDatePicker.minuteInterval = 1
        // If event != nil, we know we are in this flow while editing. This
        // fact is important in the following Create Event VC's5
        if event != nil {
            populateFields()
        }
        else{
            updateDate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchResultsTableView.isHidden = true
    }
    
    private func updateDate(){
        let date = eventDatePicker.date
        selectedDate = date
        dateComponents = eventDatePicker.calendar.dateComponents([.day, .hour, .minute], from: eventDatePicker.date)
    }
    @IBAction func onDateSelected(_ sender: Any) {
        updateDate()
    }
    
    func startFade(target: UIButton, title: String, color: UIColor, image: UIImage) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                target.alpha = 0.0
            },
            completion: {
                finished in
                if finished {
                    let image = UIImage(systemName: "circle.fill")?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(color)
                    target.setTitle(title, for: .normal)
                    target.setImage(image, for: .normal)
                    target.setTitleColor(UIColor.label, for: .normal)
                    target.titleEdgeInsets.left = 6
                    target.titleEdgeInsets.right = -6
                    self.endFade(target: target)
                }
            }
        )
    }
    
    func endFade(target: UIButton) {
        UIView.animate(
            withDuration: 1.5,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                target.alpha = 1.0
            },
            completion: nil
        )
    }
    
    @IBAction func onActivismTypePressed() {
        var filterSet: [String] = []
        for activismType in EventModel.ActivismFilterType.allCases {
            filterSet.append(activismType.rawValue)
        }
        let colorSet: [UIColor] = [UIColor.purple,
                                   UIColor.red,
                                   UIColor.cyan,
                                   UIColor.orange,
                                   UIColor.green,
                                   UIColor.systemPink]
        
        if let actionSheet = getFilterActionSheet(filters: filterSet, colors: colorSet, forActivism: true) {
            self.present(actionSheet, animated: true)
        }
    }
    
    @IBAction func onEventTypePressed() {
        var filterSet: [String] = []
        var colorSet: [UIColor] = []

        var count = 0
        for activismType in EventModel.EventFilterType.allCases {
            filterSet.append(activismType.rawValue)
            count += 1
        }
        for _ in 0...count-1 {
            colorSet.append(UIColor.lightGray)
        }
        if let actionSheet = getFilterActionSheet(filters: filterSet, colors: colorSet, forActivism: false) {
            self.present(actionSheet, animated: true)
        }
    }
    
    func getFilterActionSheet(filters: [String], colors: [UIColor], forActivism: Bool) -> UIAlertController? {
        let filterSheet = UIAlertController()
        if filters.count == colors.count {
            for i in 0...filters.count - 1 {
                let filterTitle = filters[i]
                let filterColor = colors[i]
                let image = UIImage(systemName: "circle.fill")?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(filterColor)
                let filterAction = UIAlertAction(title: filterTitle, style: .default, handler: {
                    _ in
                    if forActivism {
                        self.startFade(target: self.activismTypeFilterButton,
                                       title: filterTitle,
                                       color: filterColor, image: image!)
                        self.selectedActivismTypeFilter = filterTitle
                       
                    } else {
                        self.startFade(target: self.eventTypeFilterButton,
                                       title: filterTitle,
                                       color: filterColor,
                                       image: image!)
                        self.selectedEventTypeFilter = filterTitle
                    }
                })
                filterAction.setValue(image, forKey: "image")
                filterAction.setValue(UIColor.label, forKey: "titleTextColor")
                filterSheet.addAction(filterAction)
            }
            filterSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel))
            return filterSheet
        }
        return nil
    }
    
    @IBAction func onNextButtonPressed(_ sender: Any) {
        
        guard let eventName = eventNameField.text,
               let orgName = organizationNameField.text,
               let eventAddress = eventAddressField.text,
               let eventDescription = eventDescriptionField.text,
               let eventCoordinates = coordinates,
               let uid = auth.currentUser?.uid,
               let activismTypeFilter = selectedActivismTypeFilter,
               let eventTypeFilter = selectedEventTypeFilter,
               let eventDate = selectedDate
        else {
            var msg = "Please enter event information."
            if(coordinates == nil){
                msg = "Select an address from the search results."
            }
            let controller = UIAlertController(title: "Missing Fields",
                                               message: msg,
                                               preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: nil))
            present(controller, animated: true, completion: nil)
            return
        }
        
        if(eventDate < Date()){
            let msg = "Select a valid date in the future."
            let controller = UIAlertController(title: "Invalid Date",
                                               message: msg,
                                               preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: nil))
            present(controller, animated: true, completion: nil)
            return
        }
        
        let timeStampDate = Timestamp(date: eventDate)
        eventSoFar = [
            "name" : eventName,
            "orgName" : orgName,
            "address" : eventAddress,
            "description" : eventDescription,
            "ownerUID" : uid,
            "coordinates" : ["latitude": Float(eventCoordinates.latitude),
                             "longitude" : Float(eventCoordinates.longitude)],
            "numLikes" : 0,
            "numRSVPs" : 0,
            "activismTypeFilter" : activismTypeFilter,
            "eventTypeFilter" : eventTypeFilter,
            "date" : timeStampDate
        ]
        
        if(event != nil) {
            eventSoFar["numLikes"] = event.likeNum
            eventSoFar["numRSVPs"] = event.rsvpNum
        }

        performSegue(withIdentifier: segueId, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId,
           let nextVC = segue.destination as? AddMediaViewController {
            nextVC.event = event
            nextVC.eventSoFar = eventSoFar
            nextVC.dateComponents = dateComponents
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
        coordinates = nil
        searchCompleter.queryFragment = eventAddressField.text!
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results.filter { (a) -> Bool in
            if(a.subtitle == ""){
                return false
            }
            return true
        }
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let searchResult = searchResults[indexPath.row]
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
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
    }
    
    // Finish Editing The Text Field
    func textViewDidEndEditing(_ textView: UITextView) {
    }
    
    // Hide the keyboard when the return key pressed
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func populateFields() {
        if let uid = event.organizerUID {
            if uid == auth.currentUser?.uid {
                eventNameField.text = event.eventName
                organizationNameField.text = event.organization
                eventAddressField.text = event.location
                eventDescriptionField.text = event.description
                let activismFilter: String = event.activismType!
                var color = EventModel.returnColor(activismType: activismFilter)
                selectedActivismTypeFilter = activismFilter
                var image = UIImage(systemName: "circle.fill")?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(color)
                startFade(target: activismTypeFilterButton,
                          title: selectedActivismTypeFilter!,
                          color: color,
                          image: image!)
                let eventFilter: String = event.eventType!
                selectedEventTypeFilter = eventFilter
                color = UIColor.lightGray
                image = image?.withTintColor(color)
                startFade(target: eventTypeFilterButton,
                          title: selectedEventTypeFilter!,
                          color: color,
                          image: image!)
                let date = event.date!
                eventDatePicker.setDate(date, animated: false)
                selectedDate = date
            }
        }
    }

}
