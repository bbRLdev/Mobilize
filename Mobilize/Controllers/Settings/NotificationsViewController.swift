//
//  NotificationsViewController.swift
//  Mobilize
//
//  Created by Joseph Graham on 10/29/20.
//

import UIKit

class NotificationsViewController: UIViewController {

    override func viewDidLoad() {
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
