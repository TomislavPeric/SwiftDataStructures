//
//  FibonacciPriorityQueue.swift
//  swiftTest
//
//  Created by Tomislav Profico on 16/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class FibonacciPriorityQueue<T : Equatable & Hashable>: FibonacciHeap<T> {
    
    override init(orderFunction: @escaping (T, T) -> Bool) {
        super.init(orderFunction: orderFunction)
    }
    
    public func enqueue(element: T) {
        insert(value: element)
    }
    
    public func dequeue() -> T? {
        return extract()
    }
    
    public func increasePriority(newElement: T,oldElement: T){
        increasePriority(oldItem: oldElement, newItem: newElement)
    }
    
    

}
