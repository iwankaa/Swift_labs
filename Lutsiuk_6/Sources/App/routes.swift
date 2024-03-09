import Vapor

func routes(_ app: Application) throws {
    app.get("prediction") { req -> HoroscopeResponse in
        let birthday = try req.query.get(String.self, at: "birthday")
        let day = try req.query.get(String.self, at: "day")
        
        let horoscopeCalculator = HoroscopeCalculator()
        return horoscopeCalculator.calculateHoroscopeForDate(birthdate: birthday, horoscopeDay: day)
    }
}
