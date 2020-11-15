//
//  WelcomeViewController.swift
//  Mobilize
//
//  Created by Joseph Graham on 11/12/20.
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var user:UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.nameLabel.text = user?.first
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeSegue",
           let destinationVC = segue.destination as? UINavigationController,
           let homeVC = destinationVC.viewControllers[0] as? HomeViewController {
            homeVC.user = self.user
            }
    }
    
}
