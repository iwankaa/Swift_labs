//
//  File.swift
//  
//
//  Created by Iwanka on 24.10.2023.
//

import Foundation

class RobotCommandProcessor {
    
    var robotCommands = [Command]()
    var commandHistory = [String]()
    
    func commandToDirection() -> [String] {
            var directions = [String]()
            robotCommands.forEach { directions.append($0.getDirection()) }
            return directions
        }
    
    func newCommand(command сommand: String, at index: Int) -> Int {
            guard let command = checkCommand(сommand) else {
                return 400
            }
            
            if (index == -1 || robotCommands.isEmpty) {
                robotCommands.append(command)
            } else if (index >= 0 && index <= robotCommands.count) {
                robotCommands.insert(command, at: index)
            } else {
                return 400
            }
            
            print(robotCommands)
            commandHistory.append("Added \(сommand) at \(index)")
            
            return 200
        }
    
    private func checkCommand(_ commandStr: String) -> Command? {
        let components = commandStr.components(separatedBy: " ")
        
        guard components.count == 2 else {
            return nil
        }
        
        let commandName = components[0]
        
        var availableCommands = RobotCommands()
        
        if commandName == "forward" {
            if let commandValue = Float(components[1]) {
                availableCommands.forward = Command(name: commandName, value: commandValue)
            } else {
                return nil
            }
        } else if commandName == "right" {
            if let commandValue = Float(components[1]), commandValue >= 0.0, commandValue < 360, commandValue.truncatingRemainder(dividingBy: 90) == 0 {
                availableCommands.right = Command(name: commandName, value: commandValue)
            } else {
                return nil
            }
        } else if commandName == "left" {
            if let commandValue = Float(components[1]), commandValue >= 0.0, commandValue < 360, commandValue.truncatingRemainder(dividingBy: 90) == 0 {
                availableCommands.left = Command(name: commandName, value: commandValue)
            } else {
                return nil
            }
        }
        
        if let command = availableCommands.forward ?? availableCommands.right ?? availableCommands.left {
            return command
        } else {
            return nil
        }
    }

    func deleteCommand(at index: Int) -> Int {
            guard (0..<robotCommands.count).contains(index) else {
                return 400
            }
           
           robotCommands.remove(at: index)
           print(robotCommands)
           
           commandHistory.append("Deleted command at \(index) index")
           
           return 200
       }
    
    func getFinalPositionAngle() -> String {
            let rotationCommands = robotCommands.filter { $0.name == "right" || $0.name == "left"}
            var currentAngle = Float()
            
            rotationCommands.forEach { command in
            switch command.name {
            case "right":
                currentAngle += command.value
            case "left":
                currentAngle -= command.value
                switch currentAngle {
                case -270.0: currentAngle = 90.0
                case -180.0: currentAngle = 180.0
                case -90.0: currentAngle = 270.0
                default: break
                }
            default:
                break
            }
        }
            var finalangle = String()
            switch currentAngle {
            case 0: finalangle = Directions.up.orientation
            case 90: finalangle = Directions.right.orientation
            case 180: finalangle = Directions.down.orientation
            case 270: finalangle = Directions.left.orientation
            default: return ""
            }
            commandHistory.append("Final position angle: \(finalangle)")
            return finalangle
        }
    func getTotalRouteLength() -> String {
        var totalDistance: Float = 0.0
        
        for command in robotCommands {
            if command.name == "forward" {
                totalDistance += command.value
            }
        }
        
        let length = Distance(distancevalue: totalDistance)
        let totalroute = "\(Directions.up.orientation)(\(length.distance))"
        commandHistory.append("Total route length: \(totalroute)")
        
        return totalroute
    }
    func getFinalCoords() -> [Int] {
        let commands = robotCommands
               var currentOrientation = String()
               var coords = Coordinates(x: 0, y: 0)

               for (i, command) in commands.enumerated() {
                   if (command.name == "right" || command.name == "left") {
                       if (i > 0) {
                           currentOrientation = updateOrientation(currentOrientation, command)
                       } else {
                           currentOrientation = command.findAngle()
                       }
                   } else if command.name == "forward" {
                       let value = command.toCm()
                       switch currentOrientation {
                       case Directions.right.orientation:
                           coords.x += value
                       case Directions.left.orientation:
                           coords.x -= value
                       case Directions.up.orientation:
                           coords.y += value
                       case Directions.down.orientation:
                           coords.y -= value
                       default:
                           break;
                       }
                   }
               }
               let coord = [coords.x, coords.y]
               commandHistory.append("Final coord: \(coord)")
               return coord
    }

       
       private func updateOrientation(_ currHeading: String, _ command: Command) -> String {
           let currentAngle = Direction(orientation: currHeading)
           if command.value == 90 {
               return currentAngle.turn90Degrees(direction: command.name)
               } else if command.value == 180 {
                   return currentAngle.oppositeDirection
               } else if command.value == 270 {
                   let temp = currentAngle.turn90Degrees(direction: command.name)
                   return Direction(orientation: temp).oppositeDirection
               } else {
                   return ""
               }
       }
       
}
struct RobotCommands {
    var forward: Command?
    var right: Command?
    var left: Command?
}
struct Direction: Equatable {
    var orientation: String
    
    var oppositeDirection: String {
        switch orientation {
        case "→": return "←"
        case "←": return "→"
        case "↑": return "↓"
        case "↓": return "↑"
        default: return ""
        }
    }
    
    func turn90Degrees( direction: String) -> String {
        switch (orientation, direction) {
        case ("↑", "left"), ("↓", "right"), ("→", "up"), ("←", "down"):
            return "←"
        case ("↑", "right"), ("↓", "left"), ("→", "down"), ("←", "up"):
            return "→"
        case ("↑", "up"), ("↓", "down"), ("→", "right"), ("←", "left"):
            return "↑"
        case ("↑", "down"), ("↓", "up"), ("→", "left"), ("←", "right"):
            return "↓"
        default:
            return ""
        }
    }
}

struct Directions {
    static var up: Direction {
        return Direction(orientation: "↑")
    }
    
    static var down: Direction {
        return Direction(orientation: "↓")
    }
    
    static var right: Direction {
        return Direction(orientation: "→")
    }
    
    static var left: Direction {
        return Direction(orientation: "←")
    }
}
struct Command {
    var name: String
    var value: Float
    
       
       func getDirection() -> String {
           switch name {
           case "forward":
               let distance = Distance(distancevalue: value)
               return Directions.up.orientation + "(\(distance.distance))"
           case "right":
               return findAngle()
           case "left":
               return findAngle()
           default:
               return ""
           }
       }
       
    func findAngle() -> String {
        switch (name, value) {
        case ("right", 0), ("left", 0):
            return Directions.up.orientation
        case ("right", 90), ("left", 270):
            return Directions.right.orientation
        case ("right", 180), ("left", 180):
            return Directions.down.orientation
        case ("right", 270), ("left", 90):
            return Directions.left.orientation
        default:
            return ""
        }
    }

    
    func toCm() -> Int {
        return Int(value * 100)
    }
}
struct Coordinates {
    var x: Int
    var y: Int
}
struct Distance {
    var distancevalue: Float
    
    var distance: String {
        switch distancevalue {
        case 1.0...: return "\(distancevalue)m"
        case 0.1...1.0: return "\(distancevalue*10)dm"
        case 0.01...0.1: return "\(Int(distancevalue*100))cm"
        default: return ""
        }
    }
}


