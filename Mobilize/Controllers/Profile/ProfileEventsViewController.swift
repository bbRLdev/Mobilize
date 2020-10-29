//
//  ProfileViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/18/20.
//
import UIKit

class ProfileEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Table with tabs at top to go between events organizing and RSVPs
    @IBOutlet var eventTable: UITableView!
    
    let cellTag = "cell"
    let model: [String] = ["Organizing","RSVP'd Events"]
    var RSVPView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTable.delegate = self
        eventTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        if(RSVPView) {
            cell.textLabel?.text = "RSVP Event"
        } else {
            cell.textLabel?.text = "Organizing Event"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
            self.show(vc, sender: self)
        } else if (indexPath.row == 1) {
            let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
            self.show(vc, sender: self)
        }
    }
 
    @IBAction func RSVP(_ sender: Any) {
        RSVPView = true
        DispatchQueue.main.async { self.eventTable.reloadData() }
    }
    @IBAction func organizingEvent(_ sender: Any) {
        RSVPView = false
        DispatchQueue.main.async { self.eventTable.reloadData() }
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
