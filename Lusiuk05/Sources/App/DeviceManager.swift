//
//  File.swift
//  
//
//  Created by Iwanka on 31.10.2023.
//

import Foundation



class DeviceManager {
    
    static let shared = DeviceManager()
    var devices = [Device]()
    
    func addDevice(_ device: Device) -> Int {
        guard !device.id.isEmpty, !device.id.contains(" ") else {
            return 400
        }
        guard devices.first(where: { $0.id == device.id }) == nil else {
            return 400
        }

        if let desktopId = device.desktopId {
            guard devices.first(where: { $0.type == .desktop && $0.id == desktopId }) != nil else {
                return 400
            }
        }

        if device.type == .desktop {
            devices.append(Desktop(id: device.id, name: device.name, type: .desktop, subDeviceIds: []))
        } else {
            devices.append(device)
        }

        if let desktopId = device.desktopId,
           let desktopIndex = devices.firstIndex(where: { $0.id == desktopId }),
           let desktop = devices[desktopIndex] as? Desktop {
            desktop.subDeviceIds?.append(device.id)
            devices[desktopIndex] = desktop
        }

        devices.forEach { print($0.description) }

        return 200
    }

    
    func deleteDevice(with id: String) -> Int {
        guard let deviceIndex = devices.firstIndex(where: { $0.id == id }) else {
            return 400
        }

        devices.remove(at: deviceIndex)

        devices.forEach { device in
            if let desktop = device as? Desktop {
                desktop.subDeviceIds?.removeAll(where: { $0 == id })
            }
        }

        
        devices.filter { $0.desktopId == id }.forEach { $0.desktopId = nil }

        devices.forEach { print($0.description) }

        return 200
    }
    
    func onLight(_ isLightOn: Bool, for id: String) -> Int {
        guard let deviceIndex = devices.firstIndex(where: { $0.id == id }) else {
            return 400
        }
        
        let device = devices[deviceIndex]
        
        device.lights.forEach({ $0.lightOn = isLightOn })
        
        if device.type == .desktop {
            if let desktop = device as? Desktop {
                desktop.subDeviceIds?.forEach { subDeviceId in
                    
                    for device in devices where device.id == subDeviceId {
                        device.lights.forEach { $0.lightOn = isLightOn }
                    }
                }
            }
        }
        
        devices.forEach({ print($0.description) })
        
        return 200
    }
    
    func playLight(light newLight: Light?, for id: String) -> Int {
        guard let device = devices.first(where: { $0.id == id }) else {
            return 400
        }

        guard let light = newLight else {
            return 400
        }

        
        if let desktop = device as? Desktop {
            desktop.playLights(of: light)
        } else {
            device.playLights(of: light)
        }

        devices.forEach { print($0.description) }

        return 200
    }
    
    func getAllDevices() -> [DeviceDossierDto] {
        let dossier = devices.map { device in
            let lights = device.lights.map { effect in
                let speed: String? = effect.speed.map { String($0) }
                let type = effect.type.rawValue
                let direction = effect.direction?.rawValue
                return LightDTO(lightOn: effect.lightOn, effect: type, colors: effect.colours, speed: speed, direction: direction)
            }

            let type = device.type.rawValue
            let id = device.id
            let name = device.name ?? "\(type) \(id)"
            let desktopId: String? = (device as? Desktop)?.subDeviceIds == nil ? device.desktopId : nil
            let subdeviceIds: [String]? = (device as? Desktop)?.subDeviceIds

            return DeviceDossierDto(id: id, name: name, type: type, desktopId: desktopId, subdeviceIds: subdeviceIds, lights: lights)
        }

        return dossier
    }

}
