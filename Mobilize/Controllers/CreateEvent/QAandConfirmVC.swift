//
//  QAandConfirmVC.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/22/20.
//

import UIKit

class QAandConfirmVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createEvent(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.show(vc, sender: self)
    }
}
