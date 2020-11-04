//
//  EventInfoViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/31/20.
//

import UIKit

class EventInfoViewController: UIViewController {
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
    }
    
    @IBAction func onNextButtonPressed(_ sender: Any) {
        guard let eventName = eventNameField.text,
               let orgName = organizationNameField.text,
               let eventAddress = eventAddressField.text,
               let eventDescription = eventAddressField.text
        else {
            return
        }
        event = EventModel(name: eventName, desc: eventDescription, loc: eventAddress, org: orgName)
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId,
           let nextVC = segue.destination as? AddMediaViewController {
            nextVC.event = event
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
