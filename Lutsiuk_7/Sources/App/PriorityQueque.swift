//
//  File.swift
//  
//
//  Created by Iwanka on 13.11.2023.
//


import Foundation

public struct PriorityQueue<T: Comparable>{
        
    private var elements: [T] = []
    
    public var isEmpty: Bool { elements.isEmpty }
    
    public var peek: T? { elements.first }
    
    public var count: Int { return elements.count }
    
    
    public init(elements: [T] = []) {
        self.elements = elements
        self.elements.sort()
    }
    
    
    public mutating func enqueue(_ element: T) -> Bool {
        if let index = elementInsertion(element, in: elements) {
            elements.insert(element, at: index)
        } else {
            elements.append(element)
        }
        return true
    }
    
    public mutating func dequeue() -> T? {
        isEmpty ? nil : elements.removeFirst()
    }
    
    public func getElements() -> [T] {
        return elements
    }
    
    private func elementInsertion(_ element: T, in array: [T]) -> Int? {
        var low = 0
        var high = array.count - 1
        
        while low <= high {
            let mid = (low + high) / 2
            if array[mid] == element {
                return mid
            } else if array[mid] < element {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        
        return low
    }
}
