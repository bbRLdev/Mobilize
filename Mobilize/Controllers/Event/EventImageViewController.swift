//
//  EventImageViewController.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/17/20.
//

import UIKit
import FirebaseFirestore
import Firebase

class EventImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    
    let db = Firestore.firestore()
    
    var imageData = ["BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile",
                     "BlankProfile"]
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollection.delegate = self
        imageCollection.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! NakedImageCell
        
        //cell.backgroundColor = UIColor.black
        let curImageName = imageData[indexPath.row]
//        let curImageName = self.imageData[self.imageCounter]
//        self.imageCounter += 1
//        if self.imageCounter >= self.imageData.count {
//            self.imageCounter = 0
//        }
        
        // reference to my variable "image" in MyImageCell.swift
        cell.image.image = UIImage(named:curImageName)!
        
        let insets = UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16)
        cell.image.image = cell.image.image?.withAlignmentRectInsets(insets)
        cell.image.layer.cornerRadius = 8.0
        cell.image.layer.borderWidth = 2.0
        cell.image.clipsToBounds = true
        cell.image.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }


}

extension EventImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 2

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((imageCollection.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

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

class NakedImageCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
}
