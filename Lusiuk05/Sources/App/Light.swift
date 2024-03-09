//
//  File.swift
//  
//
//  Created by Iwanka on 31.10.2023.
//

import Foundation


enum LightType: String {
    case staticLight, blinking, waving
}

enum LightDirection: String {
    case up, down, right, left
}

class Light {
        
    var type: LightType = .staticLight
    var colours: [String] = ["#FFFFFF"]
    var speed: Double?
    var direction: LightDirection?
    var lightOn: Bool = false
    
    var description: String {
        let type = "type: \(type), "
        let colours = "colours: \(colours), "
        let speed = "speed: \(speed ?? nil), "
        let direction = "direction: \(direction?.rawValue), "
        let lightOn = "lightOn: \(lightOn);"
        return type + colours + speed + direction + lightOn
    }
    
    
    init() { }
    
    init?(type: String, colours: [String]?, speed: String? = nil, direction: String? = nil, lightOn: Bool) {
            
            guard let type = LightType(rawValue: type) else {
                return nil
            }
            self.type = type
            if speed == nil && (type == LightType.blinking || type == LightType.waving) {
                return nil
            }
        
            if let speed = speed {
            guard let speed = Double(speed), speed >= 0.0 else {
                return nil
            }
            if type != LightType.blinking && type != LightType.waving {
                return nil
            }
            self.speed = speed
            }
            if let colours = colours {
            if colours.filter({ $0.isValidHexColor() == false }).count != 0 {  return nil
                }
                self.colours = colours
            }
            
            
            if direction == nil && type == LightType.waving {
            return nil
            }
            if direction != nil && type != LightType.waving {
            return nil
            }
            if let direction = direction {
                guard let direction = LightDirection(rawValue: direction) else {
                    return nil
                }
                self.direction = direction
            }
            
            self.lightOn = lightOn
        }
}


extension String {
    func isValidHexColor() -> Bool {
        guard self.count == 7, self.hasPrefix("#") else {
            return false
        }
        return true
    }
}
