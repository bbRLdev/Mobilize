//
//  ProfileViewController.swift
//  Mobilize
//
//  Created by Brandt Swanson on 10/18/20.
//
import UIKit
import Firebase

class ProfileEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    //Table with tabs at top to go between events organizing and RSVPs
    @IBOutlet var eventTable: UITableView!
    
    let cellTag = "cell"
    let model: [String] = ["Organizing","RSVP'd Events"]
    
    var createdEvents:[String] = []
    var RSVPEvents:[String] = []
    var RSVPView = false
    
    var uid:String?
    
    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTable.delegate = self
        eventTable.dataSource = self
        // Do any additional setup after loading the view.
        //load()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        load()
        //eventTable.reloadData()
    }

    
    @IBAction func segmentChanged(_ sender: Any) {
        switch segCtrl.selectedSegmentIndex{
        case 0:
            RSVPView = false
            DispatchQueue.main.async { self.eventTable.reloadData() }
        case 1:
            RSVPView = true
            DispatchQueue.main.async { self.eventTable.reloadData() }
        default:
            print("error")
            
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if(eventTable.isEditing){
            navigationItem.rightBarButtonItem?.style = .plain
            navigationItem.rightBarButtonItem?.title = "Edit"
            
            let userID = uid
            let docRef = self.db.collection("users").document(userID!)
            var listName = ""
            var list: [String] = []
            if(RSVPView){
                listName = "RSVPEvents"
                list = RSVPEvents
                
            }
            else{
                
                listName = "createdEvents"
                list = createdEvents
            }
            print("updating doc")
            docRef.updateData([
                listName: list
            ], completion: {
                err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            })

            
        }
        else{
            navigationItem.rightBarButtonItem?.style = .done
            navigationItem.rightBarButtonItem?.title = "Done"
        }
        eventTable.isEditing = !eventTable.isEditing
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(RSVPView){
            return RSVPEvents.count
        }
        else{
            return createdEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.numberOfLines = 0
        
        var eid:String?
        if(RSVPView) {
            eid = RSVPEvents[row]
            //cell.textLabel?.text = RSVPEvents[row]
            
        } else {
            eid = createdEvents[row]
            //cell.textLabel?.text = createdEvents[row]
        }
        
        if(eid != nil){
            let docRef = self.db.collection("events").document(eid!)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    let eventName = dataDescription!["name"] as? String
                    cell.textLabel?.text = eventName
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row

        let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
        
        if(RSVPView) {
            vc.eventID = RSVPEvents[row]
            //self.show(vc, sender: self)
            
        } else {
            vc.eventID = createdEvents[row]
            //self.show(vc, sender: self)
        }
        self.show(vc, sender: self)

    }
    
    private func deleteHandler(indexPath: IndexPath){
        let row = indexPath.row
        var eid:String?
        if(RSVPView) {
            eid = RSVPEvents[row]
            RSVPEvents.remove(at: indexPath.row)
            //self.show(vc, sender: self)

        } else {
            eid = createdEvents[row]
            createdEvents.remove(at: indexPath.row)
            //self.show(vc, sender: self)
        }

        if(eid != nil){

            self.eventTable.deleteRows(at: [indexPath], with: .fade)

            db.collection("users").document(uid!).updateData(["createdEvents": FieldValue.arrayRemove([eid!])])

            db.collection("events").document(eid!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("removing event")
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let controller = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete this event? This action cannot be undone.", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title:"Yes", style: .destructive, handler: {_ in self.deleteHandler(indexPath: indexPath)}))
            controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to: IndexPath) {
        
        if(RSVPView){
            let itemToMove = RSVPEvents[indexPath.row]
            RSVPEvents.remove(at: indexPath.row)
            RSVPEvents.insert(itemToMove, at: to.row)
        }
        else{
            let itemToMove = createdEvents[indexPath.row]
            createdEvents.remove(at: indexPath.row)
            createdEvents.insert(itemToMove, at: to.row)
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
    
    func load() {
        let userID = uid
        let docRef = self.db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.createdEvents = dataDescription!["createdEvents"] as? [String] ?? []
                self.RSVPEvents = dataDescription!["RSVPEvents"] as? [String] ?? []
                DispatchQueue.main.async { self.eventTable.reloadData() }
                //self.eventTable.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }

}
