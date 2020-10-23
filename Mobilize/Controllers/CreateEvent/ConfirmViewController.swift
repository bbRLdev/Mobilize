//
//  CreateEventStory.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/22/20.
//

import UIKit
import MapKit
import SideMenu

class ConfirmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToMain(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.show(vc, sender: self)
    }
    
}
