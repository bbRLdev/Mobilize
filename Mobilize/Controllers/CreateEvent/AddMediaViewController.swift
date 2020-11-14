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
    var cellsAdded: Int = 0

    @IBOutlet weak var eventPicturesCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        eventPicturesCollection.dataSource = self
        eventPicturesCollection.delegate = self
        
        cellsAdded = 0

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
        cellsAdded = 0
        eventPicturesCollection.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventPicturesCollection.dequeueReusableCell(withReuseIdentifier: "MediaCellId", for: indexPath) as! ImageCell
                // reference to my variable "image" in MyImageCell.swift
        if(cellsAdded < images.count) {
            cell.image.image = images[indexPath.row]
        }
        let insets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        cell.image.image = cell.image.image?.withAlignmentRectInsets(insets)
        cell.image.layer.cornerRadius = 8.0
        cell.image.layer.borderWidth = 2.0
        cell.image.clipsToBounds = true
        cell.image.layer.borderColor = UIColor.lightGray.cgColor
        

        cell.editButton.layer.zPosition = 99
//        cell.editButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 4).isActive = true
//        cell.editButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 4).isActive = true

        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .large)
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .small)

        let plusCircleImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)?
            .withTintColor(.red, renderingMode: .alwaysOriginal)
        let plusImage = UIImage(systemName: "plus", withConfiguration: smallConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        let deleteImage = UIImage(systemName: "xmark", withConfiguration: smallConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.editButton.setBackgroundImage(plusCircleImage, for: .normal)
        cell.editButton.setImage(plusImage, for: .normal)
        
        if(cellsAdded < images.count) {
            cell.editButton.setImage(deleteImage, for: .normal)
        }
        
        cellsAdded += 1
        
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
        //https://stackoverflow.com/questions/35281405/fit-given-number-of-cells-in-uicollectionview-per-row
        
        
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
    @IBOutlet weak var editButton: UIButton!
}
