//
//  ReportViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/21/20.
//

import UIKit

class ReportViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var list = ["Hate Speech", "Violence", "Blocking Traffic"]
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Confirmation", message: "Submit Report?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title:"Yes", style: .default, handler: { _ in 
            self.dismiss(animated: true, completion: nil)
        }))
        controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
}
