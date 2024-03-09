//
//  File.swift
//  
//
//  Created by Iwanka on 13.11.2023.
//

import Foundation

class Register {
    private var peopleRegistry = PriorityQueue<Person>()

    public func addPerson(_ person: Person) -> Bool {
        let success = peopleRegistry.enqueue(person)
        return success
    }
    
    public func getAllPeople() -> [Person] {
        return peopleRegistry.getElements()
    }
}
