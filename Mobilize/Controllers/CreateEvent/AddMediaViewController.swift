//
//  AddMediaViewController.swift
//  Mobilize
//
//  Created by Michael Labarca on 11/3/20.
//

//MARK: TODO: fix imageref indexing
import UIKit
import FirebaseStorage
import FirebaseUI
import FirebaseAuth

class AddMediaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var event: EventModel!
    var eventSoFar: [String : Any] = [:]
    var imagePicker = UIImagePickerController()
    var images: [UIImage?] = []
    var cells: [ImageCell] = []
    let segueId = "QASegueId"
    var imageRefs: [String] = []
    
    let storage = Storage.storage()
    let auth = Auth.auth()

    
    @IBOutlet weak var eventPicturesCollection: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if event != nil {
//            // we must be editing an already created event, so
//            // load the images
//            images = retrieveImages()
//        }
//
//        setUpCells()
        imagePicker.delegate = self
        eventPicturesCollection.dataSource = self
        eventPicturesCollection.delegate = self

        //eventPicturesCollection.reloadData()
        //setUpCells()

        // Do any additional setup after loading the view.
    }
    
    // MARK: EDIT
    override func viewWillAppear(_ animated: Bool) {
        if event != nil {
            // we must be editing an already created event, so
            // load the images
            images = retrieveImages()
        }

        setUpCells()
    }
    // MARK: ENDEDIT
    
    func setUpCells() {
        var placeholderCount: Int = 0
        let storageRef = Storage.storage().reference(forURL: "gs://mobilize-77a05.appspot.com")
        
        var numImages = 0
        if images.count != 0 {
            numImages = images.count

            for i in 0...numImages - 1 {
                let imageCell = createImageCell()
                imageCell.hasImage = true
                let placeholderImage = UIImage(systemName: "questionmark")
                
                if images[i] != nil && images[i]!.isEqual(placeholderImage) {
                    let ref = storageRef.child("events/\(event.eventID!)").child(imageRefs[placeholderCount])
                    
                    // MARK: EDIT
                    imageCell.imageMeta.sd_setImage(with: ref, placeholderImage: images[i]){_,_,_,_ in
                        self.eventPicturesCollection.reloadData()

                    }
                    // MARK: ENDEDIT
                    
                    imageCell.imageIndex = i
                    imageCell.refIndex = placeholderCount
                    placeholderCount += 1
                } else if images[i] != nil {
                    imageCell.imageMeta.image = images[i]
                    imageCell.imageIndex = i
                }
                
                imageCell.editButtonMeta.tag = i
                let smallConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .small)
                let deleteImage = UIImage(systemName: "xmark", withConfiguration: smallConfig)?
                           .withTintColor(.white, renderingMode: .alwaysOriginal)
                imageCell.editButtonMeta.setImage(deleteImage, for: .normal)
                self.cells.append(imageCell)
            }
        }
        for i in numImages...7 {
            let imageCell = createImageCell()
            imageCell.editButtonMeta.tag = i
            imageCell.hasImage = false
            let smallConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .small)
            let plusImage = UIImage(systemName: "plus", withConfiguration: smallConfig)?
                       .withTintColor(.white, renderingMode: .alwaysOriginal)
            imageCell.editButtonMeta.setImage(plusImage, for: .normal)
            cells.append(imageCell)
        }
        
    }
    
    // Create a basic ImageCell by setting up the looks that are shared between all regardless of whether there
    // is an image yet.
    func createImageCell() -> ImageCell {
        let imageCell: ImageCell = ImageCell()
        let cellImage: UIImageView = UIImageView()
        let insets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        cellImage.image = cellImage.image?.withAlignmentRectInsets(insets)
        cellImage.layer.cornerRadius = 8.0
        cellImage.layer.borderWidth = 2.0
        cellImage.clipsToBounds = true
        cellImage.layer.borderColor = UIColor.lightGray.cgColor
        imageCell.imageMeta = cellImage
        
        let cellButton: UIButton = UIButton()
        cellButton.layer.zPosition = 99
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .large)
        let circleImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)?
            .withTintColor(.red, renderingMode: .alwaysOriginal)
        cellButton.setBackgroundImage(circleImage, for: .normal)
        imageCell.editButtonMeta = cellButton
        imageCell.editButtonMeta.addTarget(self, action: #selector(onAddPicturePressed(_:)), for: .touchUpInside)


        
        return imageCell
    }
    
    @IBAction func onAddPicturePressed(_ sender: UIButton) {
        if !cells[sender.tag].hasImage {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            //some edit function
            let controller = UIAlertController(title: "Delete Photo?", message: "", preferredStyle: .actionSheet)
            controller.addAction(UIAlertAction(title:"Delete", style: .destructive, handler: {
                _ in
                

                var cell = self.cells[sender.tag] //changed from let to var
                if let refIndex = cell.refIndex {
                    self.imageRefs.remove(at: refIndex)
                    self.images.remove(at: cell.imageIndex)
                } else {
                    self.images.remove(at: cell.imageIndex)
                }
                
                
                self.cells = []
                self.setUpCells()
                self.eventPicturesCollection.reloadData()
            }))
            controller.addAction(UIAlertAction(title:"Cancel", style: .cancel))
            present(controller, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            
            self.images.append(image)
            
        }
        self.cells = []
        setUpCells()
        eventPicturesCollection.reloadData()
        dismiss(animated: true, completion: nil)
    }
    

    


    @IBAction func onNextButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: segueId, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId,
           let nextVC = segue.destination as? QAandConfirmVC {
            if(event != nil){
                event.photoURLCollection = imageRefs
            }

            eventSoFar["photoIDCollection"] = nil
            var imageRefList = [[String : String]]()
            var count: Int = 0
            for ref in imageRefs {
                imageRefList.append(["\(count)" : ref])
                count += 1
            }
            eventSoFar["photoIDCollection"] = imageRefList
            nextVC.images = images
            nextVC.event = event
            nextVC.eventSoFar = eventSoFar
        }
    }
    
    // Download the images from our existing model.
    func retrieveImages() -> [UIImage?] {
        var ret: [UIImage?] = []
        
        // MARK: EDIT
        if(event.photoURLCollection.count > 0){
            for i in 0...event.photoURLCollection.count-1 {
                imageRefs.append(event.photoURLCollection[i])
                ret.append(UIImage(systemName: "questionmark"))
            }
        }
        // MARK: ENDEDIT

        return ret
    }
    

}

// UICollectionView Protocols.

extension AddMediaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
}
extension AddMediaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventPicturesCollection.dequeueReusableCell(withReuseIdentifier: "MediaCellId", for: indexPath) as! ImageCell
        let metaCell = cells[indexPath.row]
        cell.image.image = metaCell.imageMeta.image
        cell.image.layer.cornerRadius = metaCell.imageMeta.layer.cornerRadius
        cell.image.layer.borderWidth = metaCell.imageMeta.layer.borderWidth
        cell.image.clipsToBounds = metaCell.imageMeta.clipsToBounds
        cell.image.layer.borderColor = metaCell.imageMeta.layer.borderColor
        
        cell.editButton.layer.zPosition = metaCell.editButtonMeta.layer.zPosition
        cell.editButton.setBackgroundImage(metaCell.editButtonMeta.backgroundImage(for: .normal), for: .normal)
        cell.editButton.setImage(metaCell.editButtonMeta.image(for: .normal), for: .normal)
        cell.editButton.addTarget(self, action: #selector(onAddPicturePressed(_:)), for: .touchUpInside)
        cell.editButton.tag = indexPath.row
        
        return cell
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
    var hasImage: Bool = false
    var imageIndex: Int = 0
    var refIndex: Int?
    var imageMeta: UIImageView!
    var editButtonMeta: UIButton!
}
