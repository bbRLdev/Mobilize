//
//  FilterViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/28/20.
//

import UIKit



class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterStack: UIStackView!
    @IBOutlet weak var eventStack: UIStackView!
    @IBOutlet weak var radiusSlider: UISlider!
    var delegate: UIViewController!
    
    enum ActivismFilterTypes: String, CaseIterable {
        case racialJustice = "Racial Justice",
             workersRights = "Worker's Rights",
             lgbtq = "LGBTQ+ Rights",
             votersRights = "Voter's Rights",
             environment = "Environmental",
             womensRights = "Women's Rights"
    }
    
    enum EventFilterTypes: String, CaseIterable {
        case march = "March",
             protest = "Protest",
             political = "Political",
             voting = "Voting"
    }
    
    let colorSet: [UIColor] = [UIColor.purple,
                               UIColor.red,
                               UIColor.cyan,
                               UIColor.orange,
                               UIColor.green,
                               UIColor.systemPink]
    
    var activismButtonSet: [UIButton] = []
    var eventButtonSet: [UIButton] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var caseNum = 0
        for activism in ActivismFilterTypes.allCases {
            let button = UIButton()
            button.setTitle(activism.rawValue, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setImage(UIImage(systemName: "circle"), for: .normal)
            button.setImage(UIImage(systemName: "circle.fill"), for: .selected)
            button.titleEdgeInsets.left = 6
            button.titleEdgeInsets.right = -6
            button.tintColor = colorSet[caseNum]
            button.addTarget(self, action: #selector(selectFilter(_:)), for: .touchUpInside)
            activismButtonSet.append(button)
            caseNum += 1
            filterStack.addArrangedSubview(button)
        }
        
        for event in EventFilterTypes.allCases {
            let button = UIButton()
            button.setTitle(event.rawValue, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setImage(UIImage(systemName: "circle"), for: .normal)
            button.setImage(UIImage(systemName: "circle.fill"), for: .selected)
            button.titleEdgeInsets.left = 6
            button.titleEdgeInsets.right = -6
            button.tintColor = UIColor.lightGray
            button.addTarget(self, action: #selector(selectFilter(_:)), for: .touchUpInside)
            eventButtonSet.append(button)
            eventStack.addArrangedSubview(button)
        }
    }

    @IBAction func selectFilter(_ sender: UIButton!) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
        
    }
    
    func collectSelectedActivismFilters() -> [String] {
        var ret: [String] = []
        for button in activismButtonSet {
            if button.isSelected, let title = button.currentTitle {
                ret.append(title)
            }
        }
        return ret
    }
    
    func collectSelectedEventFilters() -> [String] {
        var ret: [String] = []
        for button in eventButtonSet {
            if button.isSelected, let title = button.currentTitle {
                ret.append(title)
            }
        }
        return ret
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let eventFilters = collectSelectedEventFilters()
        let activismFilters = collectSelectedActivismFilters()
        let radius = radiusSlider.value
        let homeVC = delegate as! GetFilters
        homeVC.getFilters(actFilters: eventFilters,
                          evtFilters: activismFilters,
                          radius: radius)
        // pass to main vc
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
