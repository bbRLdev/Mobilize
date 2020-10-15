//
//  HomeViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/15/20.
//
import UIKit
import MapKit
import SideMenu

class HomeViewController: UIViewController {

    
    
    var sideMenu: SideMenuNavigationController?
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu = SideMenuNavigationController(rootViewController: SideMenuListController())
        sideMenu?.leftSide = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sideNavButtonPressed(_ sender: Any) {
        present(sideMenu!, animated: true)

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
class SideMenuListController: UITableViewController {
    var items = [NavLinks.profile.rawValue, NavLinks.settings.rawValue, NavLinks.events.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    enum NavLinks: String, CaseIterable {
        case profile = "Profile", settings = "Settings", events = "Your Events"
        
    }
}
