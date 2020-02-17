//
//  Errors.swift
//  EezyNetwork
//
//  Created by Shyngys Kuandyk on 1/30/20.
//  Copyright © 2020 Shyngys Kuandyk. All rights reserved.
//

import Foundation
public enum NetworkError : String,Error {
    case parametresNil = "Parametres were Nil"
    case encodingFailed = "Parameter encoding Faile"
    case missingURL = "MissingURL"
}
