//
//  AdaptedSize.swift
//  Swift Support Codes
//
//  Created by Shyngys Kuandyk on 2/17/20.
//  Copyright © 2020 Shyngys Kuandyk. All rights reserved.
//

import Foundation
import UIKit

struct SizeForScreen {
    static func setSize(size:CGFloat) -> CGFloat {
         let size = (UIScreen.main.bounds.width/320)*size
        return size
    }
}
