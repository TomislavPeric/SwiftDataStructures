//
//  PriorityQueue.swift
//  swiftTest
//

import UIKit

//Priority Queue take most important items in front of the queue. We use Heap to implement this so this simply wraps the Heap

class PriorityQueue<T : Hashable> : HeapWithChangableElements<T> {
    
    override init(orderFunction: @escaping (T, T) -> Bool) {
        super.init(orderFunction: orderFunction)
    }
    
    public func enqueue(element: T) {
        insert(value: element)
    }
    
    public func dequeue() -> T? {
        return extract()
    }
    
}
