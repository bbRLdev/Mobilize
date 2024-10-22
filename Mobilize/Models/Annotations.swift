//
//  AnnotationModel.swift
//  Mobilize
//
//  Created by Roger Zhong on 11/5/20.
//

import Foundation
import MapKit

class EventAnnotation : NSObject, MKAnnotation {
    var eventID: String
    var likes: Int
    var date:Date?
    var activismType: String?
    var eventType: String?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var address: String?
    var subtitle: String?
    var image: UIImage?
    var colour: UIColor?

    init(eid: String, numLikes: Int) {
        eventID = eid
        likes = numLikes
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.address = nil
        self.subtitle = nil
        self.image = nil
    }
}

class EventAnnotationView: MKAnnotationView {
    
    let selectedLabel:UILabel = UILabel.init(frame:CGRect(x: 0, y: 0, width: 240, height: 38))
    
    override var annotation: MKAnnotation? {
        didSet {
            let strokeTextAttributes = [
              NSAttributedString.Key.strokeColor : UIColor.white,
                NSAttributedString.Key.foregroundColor : UIColor.darkGray,
              NSAttributedString.Key.strokeWidth : -3.0,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: UIFont.Weight(rawValue: 0.8))]
            
              as [NSAttributedString.Key : Any]

            selectedLabel.attributedText = NSMutableAttributedString(string: (annotation?.title ?? "")!, attributes: strokeTextAttributes)
            
            selectedLabel.textAlignment = .center
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

class EventMapClusterView: MKAnnotationView {

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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
