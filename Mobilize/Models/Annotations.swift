//
//  AnnotationModel.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/5/20.
//

import Foundation
import MapKit

//class AnnotationModel: MKPointAnnotation{
//    var eventID: String
//    var date:Date?
//    var activismType: String?
//    init(eid: String){
//        eventID = eid
//    }
//}

class EventAnnotation : NSObject, MKAnnotation {
    var eventID: String
    var likes: Int
    var date:Date?
    var activismType: String?
    var eventType: String?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var colour: UIColor?

    init(eid: String, numLikes: Int) {
        eventID = eid
        likes = numLikes
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.image = nil
        //self.colour = UIColor.white
    }
}

class EventAnnotationView: MKAnnotationView {
    //private var imageView: UIImageView!
    let selectedLabel:UILabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: 240, height: 38))
    
    override var annotation: MKAnnotation? {
        didSet {
            
            selectedLabel.text = annotation?.title as? String
            selectedLabel.textColor = UIColor.darkGray
            
            selectedLabel.textAlignment = .center
            selectedLabel.font = UIFont.init(name: "HelveticaBold", size: 8)
            //selectedLabel.backgroundColor = UIColor.white
            //selectedLabel.layer.borderColor = UIColor.darkGray.cgColor
            //selectedLabel.layer.borderWidth = 2
            selectedLabel.layer.cornerRadius = 5
            selectedLabel.layer.masksToBounds = true

            selectedLabel.center.x = 0.5 * self.frame.size.width;
            selectedLabel.center.y = 1 * self.frame.size.height + 5;
            self.addSubview(selectedLabel)
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        super.setSelected(false, animated: false)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        if(selected)
        {
            selectedLabel.removeFromSuperview()
        }
        else
        {
            self.addSubview(selectedLabel)
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LocationDataMapClusterView: MKAnnotationView {

    private let countLabel = UILabel()

    override var annotation: MKAnnotation? {
        didSet {
             guard let annotation = annotation as? MKClusterAnnotation else {
                assertionFailure("Using LocationDataMapClusterView with wrong annotation type")
                return
            }

            countLabel.text = annotation.memberAnnotations.count < 100 ? "\(annotation.memberAnnotations.count)" : "99+"
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        displayPriority = .defaultHigh
        collisionMode = .circle

        frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)

       
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
    }
}
