//
//  File.swift
//  
//
//  Created by Iwanka on 07.11.2023.
//

import Foundation
import Vapor

enum Zodiac: String {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces
}
struct HoroscopeRequest: Decodable {
    let date: String
    let horoscope: String
    let icon: String
    let id: Int
    let sign: String
}

struct HoroscopeResponse: Encodable, Content {
    let sign: String
    let prediction: String
}

class HoroscopeCalculator {
    func getZodiacSign(day: Int, month: Int) -> String? {
        let zodiacSignData: [(month: Int, dayRange: ClosedRange<Int>, sign: String)] = [
            (3, 21...31, Zodiac.aries.rawValue),
            (4, 1...19, Zodiac.aries.rawValue),
            (4, 20...30, Zodiac.taurus.rawValue),
            (5, 1...20, Zodiac.taurus.rawValue),
            (5, 21...31, Zodiac.gemini.rawValue),
            (6, 1...20, Zodiac.gemini.rawValue),
            (6, 21...30, Zodiac.cancer.rawValue),
            (7, 1...22, Zodiac.cancer.rawValue),
            (7, 23...31, Zodiac.leo.rawValue),
            (8, 1...22, Zodiac.leo.rawValue),
            (8, 23...31, Zodiac.virgo.rawValue),
            (9, 1...22, Zodiac.virgo.rawValue),
            (9, 23...30, Zodiac.libra.rawValue),
            (10, 1...22, Zodiac.libra.rawValue),
            (10, 23...31, Zodiac.scorpio.rawValue),
            (11, 1...21, Zodiac.scorpio.rawValue),
            (11, 22...30, Zodiac.sagittarius.rawValue),
            (12, 1...21, Zodiac.sagittarius.rawValue),
            (12, 22...31, Zodiac.capricorn.rawValue),
            (1, 1...19, Zodiac.capricorn.rawValue),
            (1, 20...31, Zodiac.aquarius.rawValue),
            (2, 1...18, Zodiac.aquarius.rawValue),
            (2, 19...29, Zodiac.pisces.rawValue),
            (3, 1...20, Zodiac.pisces.rawValue)
        ]

        for data in zodiacSignData {
            if month == data.month && data.dayRange.contains(day) {
                            return data.sign
            }
        }

        return nil
    }
    
    func calculateHoroscopeForDate(birthdate: String, horoscopeDay: String) -> HoroscopeResponse {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        if horoscopeDay.isEmpty {
            return HoroscopeResponse(sign: "Check your data", prediction: "Check your data")
        }
        
        guard let validBirthDate = dateFormatter.date(from: birthdate) else {
            return HoroscopeResponse(sign: "Check your data", prediction: "Check your data")
        }
        
        let calendar = Calendar.current
        let birthdateComponents = calendar.dateComponents([.month, .day], from: validBirthDate)
        
        guard let zodiacSign = getZodiacSign(day: birthdateComponents.day!, month: birthdateComponents.month!) else {
            return HoroscopeResponse(sign: "Check your data", prediction: "Check your data")
        }
                        
        let horoscopeRequestData: HoroscopeRequest

        let currentDate = Date()

        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateString: String?
        
        switch horoscopeDay {
        case "today":
            dateString = dateFormatter.string(from: currentDate)
            
        case "yesterday":
            let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate)
            dateString = dateFormatter.string(from: yesterday!)
            
        case "tomorrow":
            var tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)
            tomorrow = calendar.date(byAdding: .year, value: -1, to: currentDate)
            dateString = dateFormatter.string(from: tomorrow!)
            
        default:
            dateString = nil
        }
        
        if dateString == nil {
            return HoroscopeResponse(sign: "Check your data", prediction: "Check your data")
        }
        
        if let url = URL(string: "https://newastro.vercel.app/\(zodiacSign)?date=\(dateString!)"),
           let data = try? Data(contentsOf: url),
           let decodedData = try? JSONDecoder().decode(HoroscopeRequest.self, from: data) {
            horoscopeRequestData = decodedData
        } else {
            return HoroscopeResponse(sign: "Check your data", prediction: "Check your data")
        }
        
        return HoroscopeResponse(
            sign: horoscopeRequestData.sign,
            prediction: horoscopeRequestData.horoscope)
    }
}
