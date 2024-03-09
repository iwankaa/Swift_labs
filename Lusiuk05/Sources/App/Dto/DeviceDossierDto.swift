//
//  DeviceDossierDto.swift
//  
//
//  Created by Alex Frankiv on 16.10.2021.
//

import Foundation
import Vapor

struct DeviceDossierDto: Codable, Content {
    let id: String
    let name: String
    let type: String
    let desktopId: String?
    let subdeviceIds: [String]?
    let lights: [LightDTO]
}
