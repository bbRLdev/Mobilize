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
    
    private let refreshControl = UIRefreshControl()
    
    //Table with tabs at top to go between events organizing and RSVPs
    @IBOutlet var eventTable: UITableView!
    
    let cellTag = "cell"
    let model: [String] = ["Organizing","RSVP'd Events"]
    
    var createdEvents:[String] = []
    var rsvpEvents:[String] = []
    var likedEvents:[String] = []
    
    var RSVPView = true
    
    var uid:String?
    
    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTable.delegate = self
        eventTable.dataSource = self
        eventTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        // Do any additional setup after loading the view.
        //load()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshTable()
    }

    @objc private func refreshTable() {
        load()
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch segCtrl.selectedSegmentIndex{
        case 0:
            RSVPView = true
            DispatchQueue.main.async { self.eventTable.reloadData() }
        case 1:
            RSVPView = false
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
                listName = "rsvpEvents"
                list = rsvpEvents
                
            }
            else{
                
                listName = "createdEvents"
                list = createdEvents
            }

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
            return rsvpEvents.count
        }
        else{
            return createdEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTag, for: indexPath as IndexPath)
        let row = indexPath.row
        //cell.textLabel?.numberOfLines = 0
        
        var eid:String?
        if(RSVPView) {
            eid = rsvpEvents[row]
            //cell.textLabel?.text = rsvpEvents[row]
            
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
                    let orgName = dataDescription!["orgName"] as? String
                    let pendingQuestions = dataDescription!["pendingQuestions"] as? [String] ?? []
                    
                    
                    cell.textLabel?.text = eventName
                    if(self.RSVPView){
                        cell.detailTextLabel?.text = orgName
                    }
                    else{
                        cell.detailTextLabel?.text = "Pending Questions: \(pendingQuestions.count)"
                    }
                    
                    //date later?
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

        if(RSVPView) {
            let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
            vc.eventID = rsvpEvents[row]
            self.show(vc, sender: self)
        }
        else {
            let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PendingQuestions") as! PendingQuestionsViewController
            vc.eventID = createdEvents[row]
            self.show(vc, sender: self)
        }
        
    }
    
    private func deleteHandler(indexPath: IndexPath){
        let row = indexPath.row
        var eid:String?
        if(RSVPView) {
            eid = rsvpEvents[row]
            rsvpEvents.remove(at: indexPath.row)
            //self.show(vc, sender: self)
            
            //self.eventTable.deleteRows(at: [indexPath], with: .fade)

            db.collection("users").document(uid!).updateData(["rsvpEvents": FieldValue.arrayRemove([eid!])])

            db.collection("events").document(eid!).updateData([
                "numRSVPs": FieldValue.increment(Int64(-1))
            ], completion: {
                err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            })

        } else {
            eid = createdEvents[row]
            createdEvents.remove(at: indexPath.row)
            //self.show(vc, sender: self)
            //self.eventTable.deleteRows(at: [indexPath], with: .fade)

            db.collection("users").document(uid!).updateData(["createdEvents": FieldValue.arrayRemove([eid!])])

            db.collection("events").document(eid!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("removing event")
                }
            }
        }
        self.eventTable.deleteRows(at: [indexPath], with: .fade)

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            var msg = ""
            if(RSVPView){
                msg = "Remove RSVP?"
            }
            else{
                msg = "Are you sure you want to delete this event? This action cannot be undone."
            }
            
            let controller = UIAlertController(title: "Delete Event", message: msg, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title:"Yes", style: .destructive, handler: {_ in self.deleteHandler(indexPath: indexPath)}))
            controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to: IndexPath) {
        
        if(RSVPView){
            let itemToMove = rsvpEvents[indexPath.row]
            rsvpEvents.remove(at: indexPath.row)
            rsvpEvents.insert(itemToMove, at: to.row)
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
    
    private func load() {

        let userRef = self.db.collection("users").document(uid!)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                self.createdEvents = dataDescription!["createdEvents"] as? [String] ?? []
                self.rsvpEvents = dataDescription!["rsvpEvents"] as? [String] ?? []
                self.likedEvents = dataDescription!["likedEvents"] as? [String] ?? []
                
                DispatchQueue.main.async { self.eventTable.reloadData() }
                self.checkData(userRef: userRef)
                self.refreshControl.endRefreshing()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func checkData(userRef: DocumentReference){
        let createdList = createdEvents
        let RSVPList = rsvpEvents
        let likedList = likedEvents
        
        for created in createdList{
            //print(created)
            let eventRef = self.db.collection("events").document(created)
            eventRef.getDocument{ (document, error) in
                if let document = document, document.exists{}
                else{
                    if let idx = self.createdEvents.firstIndex(of: created){
                        self.createdEvents.remove(at: idx)
                        DispatchQueue.main.async { self.eventTable.reloadData() }
                    }
                    userRef.updateData(["createdEvents": FieldValue.arrayRemove([created])])
                }

            }
        }
        for rsvped in RSVPList{
            let eventRef = self.db.collection("events").document(rsvped)
            eventRef.getDocument{ (document, error) in
                if let document = document, document.exists{}
                else{
                    if let idx = self.rsvpEvents.firstIndex(of: rsvped){
                        self.rsvpEvents.remove(at: idx)
                        DispatchQueue.main.async { self.eventTable.reloadData() }
                    }
                    userRef.updateData(["rsvpEvents": FieldValue.arrayRemove([rsvped])])
                }

            }
        }
        for liked in likedList{
            let eventRef = self.db.collection("events").document(liked)
            eventRef.getDocument{ (document, error) in
                if let document = document, document.exists{}
                else{
                    if let idx = self.likedEvents.firstIndex(of: liked){
                        self.likedEvents.remove(at: idx)
                        DispatchQueue.main.async { self.eventTable.reloadData() }
                    }
                    userRef.updateData(["likedEvents": FieldValue.arrayRemove([liked])])
                }

            }
        }
    }

}


