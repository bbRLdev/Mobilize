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
    var eventSoFar: [String : Any] = [:]
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
                // reference to my variable "image" in MyImageCell.swift
        cell.image.image = images[indexPath.row]
        cell.image.layer.cornerRadius = 8.0
        cell.image.clipsToBounds = true
        
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
            nextVC.eventSoFar = eventSoFar
        }
    }
    

    

}

extension AddMediaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Big thanks to stackoverflow for giving me this code
        // https://stackoverflow.com/questions/35281405/fit-given-number-of-cells-in-uicollectionview-per-row
        
        
        let noOfCellsInRow = 2

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((eventPicturesCollection.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
    
    // Asks the delegate for the spacing between successive rows or columns of a section.
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSectionAt: Int) -> CGFloat {
        let spacing: CGFloat = 8.0
        return spacing
    }
    
    // Asks the delegate for the spacing between successive items in the rows or columns of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let spacing: CGFloat = 8.0
        return spacing
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}
