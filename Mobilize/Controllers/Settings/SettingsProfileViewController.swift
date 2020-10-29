//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/15/20.
//
import UIKit

class SettingsProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let options = ["Your events", "Settings"]
    let cellTag = "cell"
    @IBOutlet var name: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var Options: UITableView!
    @IBOutlet var organization: UILabel!
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
        print(row)
        cell.textLabel?.text = options[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            performSegue(withIdentifier: "events", sender: self)
        }
        if(indexPath.row == 1) {
            performSegue(withIdentifier: "settings", sender: self)
        }
    }
}
