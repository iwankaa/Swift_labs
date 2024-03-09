import Vapor


func routes(_ app: Application) throws {
    let register = Register()

    app.post("user") { req -> Int in
        let person = try req.content.decode(Person.self)
        let success = register.addPerson(person)
        if success {
               return 200
           } else {
               return 400
           }
    }

    app.get("user") { req -> [Person] in
        return register.getAllPeople()
    }
}
