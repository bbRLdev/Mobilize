//
//  CreateEventStory.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/22/20.
//

import UIKit

class ConfirmViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmButton.layer.cornerRadius = 4
        backButton.layer.cornerRadius = 4
    }
    
    @IBAction func backToMain(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
