//
//  ExtensionAddSubviewsByArray.swift
//  Swift Support Codes
//
//  Created by Shyngys Kuandyk on 2/17/20.
//  Copyright © 2020 Shyngys Kuandyk. All rights reserved.
//
// Add list of views by array

import Foundation
import UIKit
extension UIView {
    func addSubViews(withList views: [UIView]) -> Void {
        for view in views {
            self.addSubview(view)
        }
    }
    
    //Remove Constraints
    func removeConstraints() {
        removeConstraints(constraints)
    }
    
    func deactivateAllConstraints() {
        NSLayoutConstraint.deactivate(getAllConstraints())
    }
    
    func getAllSubviews() -> [UIView] {
        return UIView.getAllSubviews(view: self)
    }
    
    func getAllConstraints() -> [NSLayoutConstraint] {
        
        var subviewsConstaints = getAllSubviews().flatMap { (view) -> [NSLayoutConstraint] in
            return view.constraints
        }
        
        if let superview = self.superview {
            
            subviewsConstaints += superview.constraints.compactMap { (constraint) -> NSLayoutConstraint? in
                if let view = constraint.firstItem as? UIView {
                    if view == self {
                        return constraint
                    }
                }
                return nil
            }
        }
        
        return subviewsConstaints + constraints
    }
    
    class func getAllSubviews(view: UIView) -> [UIView] {
        return view.subviews.flatMap { subView -> [UIView] in
            return [subView] + getAllSubviews(view: subView)
        }
    }
}
