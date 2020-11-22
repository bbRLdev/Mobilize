//
//  PendingQuestionsViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/21/20.
//

import UIKit
import Firebase

class PendingQuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let refreshControl = UIRefreshControl()

    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    
    var eventID:String?
    
    var questions:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        loadQuestions()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshTable()
    }
    
    @objc private func refreshTable() {
        loadQuestions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        if(tableView.isEditing){
            navigationItem.rightBarButtonItem?.style = .plain
            navigationItem.rightBarButtonItem?.title = "Edit"
            
            let docRef = self.db.collection("events").document(eventID!)
            let listName = "pendingQuestions"

            docRef.updateData([
                listName: questions
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
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func viewButtonPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "EventStory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventView") as! EventDetailsViewController
        vc.eventID = eventID
        self.show(vc, sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "qCell", for: indexPath)
        
        cell.textLabel?.text = questions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row

        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AnswerQuestion") as! AnswerQuestionViewController
        
        vc.modalPresentationStyle = .pageSheet
        vc.question = questions[row]
        vc.indexPath = indexPath
        vc.parentVC = self

        self.present(vc, animated: true, completion: nil)

    }
    
    func deleteHandler(indexPath: IndexPath){
        let row = indexPath.row
        
        let toRemove = questions[row]
        questions.remove(at: indexPath.row)

        db.collection("events").document(eventID!).updateData(["pendingQuestions": FieldValue.arrayRemove([toRemove])],
            completion: {
            err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        })

        self.tableView.deleteRows(at: [indexPath], with: .left)

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteHandler(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to: IndexPath) {
        let itemToMove = questions[indexPath.row]
        questions.remove(at: indexPath.row)
        questions.insert(itemToMove, at: to.row)
        
    }
    

    private func loadQuestions(){
        let eid = eventID
        let docRef = self.db.collection("events").document(eid!)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.questions = dataDescription?["pendingQuestions"] as? [String] ?? []
                
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
                self.refreshControl.endRefreshing()
            }
        }
    }

}

class AnswerQuestionViewController : UIViewController{
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var qTextView: UITextView!
    
    @IBOutlet weak var aTextView: UITextView!
    
    var question = ""
    var indexPath:IndexPath?
    var parentVC:PendingQuestionsViewController?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        qTextView.text = question
        qTextView.layer.borderColor = UIColor.lightGray.cgColor
        qTextView.layer.borderWidth = 1
        aTextView.layer.borderColor = UIColor.lightGray.cgColor
        aTextView.layer.borderWidth = 1
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if(aTextView.text != ""){
            let controller = UIAlertController(title: "Save Question", message: "Choosing yes will save the response to the event page.", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title:"Yes", style: .default, handler: { [self]_ in
                parentVC?.deleteHandler(indexPath: indexPath!)
                let eid = parentVC?.eventID
                
                let temp: [String:String] = ["question": qTextView.text, "answer": aTextView.text]
                let docRef = db.collection("events").document(eid!)
                docRef.updateData(["questions": FieldValue.arrayUnion([temp])])
                self.dismiss(animated: true, completion: nil)
            }))
            controller.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
            present(controller, animated: true, completion: nil)

        }

        
    }
    
    
}
