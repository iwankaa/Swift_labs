//
//  File.swift
//  
//
//  Created by Iwanka on 31.10.2023.
//

import Foundation


enum DeviceType: String {
    case lamp, mouse, cooler, phones, desktop
}

class Device {
    var id: String
    var name: String?
    var type: DeviceType
    var desktopId: String?
    var lights: [Light]
    
    var description: String {
        let id = "id: \(self.id), "
        let name = "name: \(self.name ?? "\(type) \(self.id)"), "
        let type = "type: \(self.type), "
        let lights = "lights: \(self.lights.map { $0.description }), "
        let desktopId = "desktopId: \(self.desktopId ?? "nil")"
        return id + name + type + lights + desktopId
    }
    
    init(id: String, name: String?, type: DeviceType, lights: [Light] = [], desktopId: String?) {
        self.id = id
        self.name = name
        self.type = type
        self.lights = lights
        self.desktopId = desktopId
    }
    
    func playLights(of light: Light) {
        lights.append(light)
    }
}
