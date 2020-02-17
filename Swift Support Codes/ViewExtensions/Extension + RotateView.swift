//
//  Extension + RotateView.swift
//  Swift Support Codes
//
//  Created by Shyngys Kuandyk on 2/17/20.
//  Copyright © 2020 Shyngys Kuandyk. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    func rotate(degrees: CGFloat) {
        rotate(radians: CGFloat.pi * degrees / 180.0)
    }

    func rotate(radians: CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}
