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
        self.navigationController?.popToRootViewController(animated: true)
    }
}
