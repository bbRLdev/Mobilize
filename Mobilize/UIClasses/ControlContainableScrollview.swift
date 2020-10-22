//
//  ControlContainableScrollview.swift
//  Mobilize
//
//  Created by Michael Labarca on 10/22/20.
//

import UIKit


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
final class ControlContainableScrollView: UIScrollView {
     
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl
            && !(view is UITextInput)
            && !(view is UISlider)
            && !(view is UISwitch) {
            return true
        }
 
        return super.touchesShouldCancel(in: view)
    }
     
}
