//
//  NotificationsViewController.swift
//  Mobilize
//
//  Created by Joseph Graham on 10/29/20.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        button.layer.cornerRadius = 4
        super.viewDidLoad()
    }
    @IBAction func openSettingsPushed(_ sender: Any) {
        if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
}
