import Vapor
func routes(_ app: Application) throws {

    // 1
    app.post("device") { req -> Int in
        let id = try req.content.get(String.self, at: "id")
        let name = try? req.content.get(String.self, at: "custom_name")
        let deviceType = try req.content.get(String.self, at: "type")
        let desktopId = try? req.content.get(String.self, at: "desktop_id")
        
        guard let type = DeviceType(rawValue: deviceType) else {
            return 400
        }
        
        let newDevice = Device(id: id, name: name, type: type, desktopId: desktopId)
        let addedDevice = DeviceManager.shared.addDevice(newDevice)
        return addedDevice
    }
    
    // 2
    app.delete("device") { req -> Int in
        let id = try req.content.get(String.self, at: "id")
        
        return DeviceManager.shared.deleteDevice(with: id)
    }

    // 3
    app.put("device", "light") { req -> Int in
        let id = try req.content.get(String.self, at: "id")
        let isLightOn = try req.content.get(Bool.self, at: "on")
        
        return DeviceManager.shared.onLight(isLightOn, for: id)
    }

    // 4
    app.put("device", "effect") { req -> Int in
        let id = try req.content.get(String.self, at: "id")
        let type = try req.content.get(String.self, at: "effect_name")
        let colors = try? req.content.get([String]?.self, at: "colors")
        let speed = try? req.content.get(String?.self, at: "speed")
        let direction = try? req.content.get(String?.self, at: "direction")

        let newLight = Light(type: type, colours: colors, speed: speed, direction: direction, lightOn: false)
        return DeviceManager.shared.playLight(light: newLight, for: id)
    }

    // 5
    app.get("devices") { req -> [DeviceDossierDto] in
        return DeviceManager.shared.getAllDevices()
    }
}
