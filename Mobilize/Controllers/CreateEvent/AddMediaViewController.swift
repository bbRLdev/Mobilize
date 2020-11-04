//
//  AddMediaViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 11/3/20.
//

import UIKit

class AddMediaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegate {

    
    
    var event: EventModel!
    var imagePicker = UIImagePickerController()
    var images: [UIImage] = []
    let segueId = "QASegueId"

    @IBOutlet weak var eventPicturesCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        eventPicturesCollection.dataSource = self
        eventPicturesCollection.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onAddPicturePressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.images.append(image)
        }
        eventPicturesCollection.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventPicturesCollection.dequeueReusableCell(withReuseIdentifier: "MediaCellId", for: indexPath) as! ImageCell
        
        cell.backgroundColor = UIColor.black
        // reference to my variable "image" in MyImageCell.swift
        print(images[indexPath.row])
        cell.image.image = images[indexPath.row]
        return cell
        
    }

    @IBAction func onNextButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId,
           let nextVC = segue.destination as? QAandConfirmVC{
            nextVC.images = images
            nextVC.event = event
        }
    }
    

}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}
