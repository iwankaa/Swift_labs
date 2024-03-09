//
//  File.swift
//  
//
//  Created by Iwanka on 31.10.2023.
//

import Foundation
import Vapor

struct LightDTO: Codable, Content {
    let lightOn: Bool
    let effect: String
    let colors: [String]
    let speed: String?
    let direction: String?
}
