//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/15/20.
//
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let options = ["Edit Profile", "Notifications"]
    let cellTag = "cell"
    @IBOutlet var Options: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Options.delegate = self
        Options.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = options[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            print("here")
            performSegue(withIdentifier: "edit", sender: self)
        }
        if(indexPath.row == 1) {
            performSegue(withIdentifier: "notifications", sender: self)
        }
    }
}
