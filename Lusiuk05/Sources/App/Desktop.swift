//
//  File.swift
//  
//
//  Created by Iwanka on 31.10.2023.
//

import Foundation


class Desktop: Device {
    var subDeviceIds: [String]?
    
    override var description: String {
        let id = "id: \(self.id), "
        let defaultName = "\(self.type) \(self.id)"
        let name = "name: \(self.name ?? defaultName), "
        let type = "type: \(self.type), "
        let subDeviceIds = "subDeviceIds: \(self.subDeviceIds ?? [])"
        return id + name + type + subDeviceIds
    }
    
    init(id: String, name: String?, type: DeviceType, subDeviceIds: [String]?) {
        super.init(id: id, name: name, type: type, desktopId: nil)
        self.subDeviceIds = subDeviceIds
    }
    
    override func playLights(of light: Light) {
        let deviceManager = DeviceManager.shared
        
        subDeviceIds?.forEach { id in
            deviceManager.devices.filter { $0.id == id }.forEach { $0.playLights(of: light) }
        }
    }
}
