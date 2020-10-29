//
//  CreateEventStory.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/22/20.
//

import UIKit

class ConfirmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backToMain(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.show(vc, sender: self)
    }
    
}
