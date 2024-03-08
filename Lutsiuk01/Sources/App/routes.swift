import Vapor

func routes(_ app: Application) throws {

    app.post("validate") { req -> Int in
        let email = try req.content.get(String.self, at: "email")
        let password = try req.content.get(String.self, at: "password")

        req.logger.info("Parsed param `email`: \(email)")
        req.logger.info("Parsed param `password`: \(password)")

        if isValidEmail(email) && isValidPassword(password) {
            return 200
        } else {
            return 400
        }
    }
}

func isValidEmail(_ email: String) -> Bool {
    guard !email.isEmpty, email.contains("@") else {
        return false
    }
    let components = email.components(separatedBy: "@")
    
    if components.count != 2 {
        return false
    }
    
    let username = components[0]
    let domainParts = components[1].components(separatedBy: ".")
    
    if username.isEmpty || domainParts.count != 2 || domainParts[0].isEmpty || domainParts[1].isEmpty {
        return false
    }
    
    return username.rangeOfCharacter(from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")) != nil
}

func isValidPassword(_ password: String) -> Bool {
    guard !password.isEmpty else {
        return false
    }

    guard password.contains(where: { $0.isUppercase }) else {
        return false
    }

    guard password.contains(where: { $0.isLowercase }) else {
        return false
    }

    guard password.contains(where: { $0.isNumber }) else {
        return false
    }

    let specialCharacters = "+-_#$"
    guard password.contains(where: { specialCharacters.contains($0) }) else {
        return false
    }
    

    guard password.count > 8 else {
        return false
    }

    return password.rangeOfCharacter(from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) != nil
}




