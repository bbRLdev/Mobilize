//
//  ClusterPinViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/20/20.
//

import UIKit
import MapKit

class ClusterPinViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    var pins: [MKAnnotation]?

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        pins?.sort(by: { (a1, a2) -> Bool in
            if let s1 = a1.title {
                if let s2 = a2.title {
                    return s1! < s2!
                }
            }
            return false
        })
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pins?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?{
      return "Events Near Location"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath as IndexPath)
        
        let row = indexPath.row
        let pin = pins?[row] as? EventAnnotation
        cell.textLabel?.text = pin?.title
        cell.detailTextLabel?.text = pin?.subtitle
        let activismType = pin?.activismType
        let color = EventModel.returnColor(activismType: activismType!)
        let image = UIImage(systemName: "circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(color)
        cell.imageView?.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        let pin = pins?[row] as? EventAnnotation

        let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
        
        vc.eventID = pin?.eventID
        
        //vc.modalPresentationStyle = .fullScreen
        
        self.show(vc, sender: self)
        //self.present(vc, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }

}
