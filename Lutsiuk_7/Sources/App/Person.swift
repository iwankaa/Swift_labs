//
//  File.swift
//  
//
//  Created by Iwanka on 13.11.2023.
//


import Foundation
import Vapor

enum Occupation: String, Content {
    case med_worker_covid
    case elderly_worker
    case elderly_resident
    case soldiers_at_war
    case med_worker
    case social_workers
    case critical_security_service
    case education
    case prison_worker
    case prisoner
    case other
}

struct Person: Codable, Content {
    let name: String
    let age: Int
    let occupation: Occupation
    let has_chronical_illness: Bool
    
}

extension Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.getPriority() < rhs.getPriority()

    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        if lhs.name == rhs.name &&
            lhs.age == rhs.age &&
            lhs.has_chronical_illness == rhs.has_chronical_illness &&
            lhs.occupation.rawValue == rhs.occupation.rawValue
        {
            return true
        }
        return false
    }
    
    static func compareByPriority(person1: Person, person2: Person) -> Bool {
        if person1.getPriority() < person2.getPriority() {
            return true
        }
        return false
    }
    
    func getPriority() -> Int {
        switch (occupation, age, has_chronical_illness) {
        case (.med_worker_covid, _,_), (.elderly_worker, _,_), (.elderly_resident, _,_), (.soldiers_at_war, _,_):
            return 1
        case (.med_worker, _,_), (_, 80...,_),(.social_workers, _,_) :
            return 2
        case (_, 65...79,_),(.critical_security_service, _,_), (.education, _,_):
            return 3
        case (_, 60...64,_),(.prison_worker, _,_), (.prisoner, _,_),(_,_,true) :
            return 4
        case (.other, 18...59,_):
            return 5
        default:
            return 6
        }
    }
}
