//
//  FilterViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/28/20.
//

import UIKit



class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterStack: UIStackView!
    
    enum ActivismFilterTypes: String, CaseIterable {
        case racialJustice = "Racial Justice",
             workersRights = "Worker's Rights",
             lgbtq = "LGBTQ+ Rights",
             votersRights = "Voter's Rights",
             environment = "Environmental",
             womensRights = "Women's Rights"
    }
    
    let colorSet: [UIColor] = [UIColor.purple,
                               UIColor.red,
                               UIColor.cyan,
                               UIColor.orange,
                               UIColor.green,
                               UIColor.systemPink]
    
    var activismButtonSet: [UIButton] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var caseNum = 0
        for activism in ActivismFilterTypes.allCases {
            let button = UIButton()
            button.setTitle(activism.rawValue, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            button.setImage(UIImage(systemName: "circle"), for: .selected)
            button.titleEdgeInsets.left = 12
            button.titleEdgeInsets.right = -12
            button.tintColor = colorSet[caseNum]
            button.addTarget(self, action: #selector(selectActivismFilter(_:)), for: .touchUpInside)
            activismButtonSet.append(button)
            caseNum += 1
            filterStack.addArrangedSubview(button)
        }
    }

    @objc func selectActivismFilter(_ sender: UIButton!) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
        
    }
    
    func collectSelectedActivismFilter() -> [String] {
        var ret: [String] = []
        for button in activismButtonSet {
            if button.isSelected, let title = button.currentTitle {
                ret.append(title)
            }
        }
        return ret
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
