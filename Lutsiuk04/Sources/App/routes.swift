import Vapor

func routes(_ app: Application) throws {
    let robot = RobotCommandProcessor()

    // 1
    app.get("commands") { req -> [String] in
        return robot.commandToDirection()
    }

    // 2.1
    app.post("command") { req -> Int in
        let сommand = try req.content.get(String.self, at: "command")
        let index = try req.content.get(Int.self, at: "index")
        return robot.newCommand(command: сommand, at: index)
        }

    // 2.2
    app.delete("command") { req -> Int in
            let index = try req.content.get(Int.self, at: "index")
            return robot.deleteCommand(at: index)
        }

    // 3
    app.get("final_position_angle") { req -> String in
            return robot.getFinalPositionAngle()
        }
    
    // 4
    app.get("total_route_length") { req -> String in
            return robot.getTotalRouteLength()
        }

    // 5
    app.get("final_coord") { req -> [Int] in
            return robot.getFinalCoords()
        }


    // 6
    app.get("test_program_log") { req -> [String] in
            return robot.commandHistory
        }
}
