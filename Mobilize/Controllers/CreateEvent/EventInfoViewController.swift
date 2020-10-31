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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventDescriptionField.layer.borderWidth = 0.5
        eventDescriptionField.layer.cornerRadius = 5.0;
        eventDescriptionField.clipsToBounds = true;
        eventDescriptionField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        // Do any additional setup after loading the view.
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
