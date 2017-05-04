//
//  Queue.swift
//  swiftTest
//
//  Created by Tomislav Profico on 06/12/16.
//  Copyright © 2016 Tomislav Profico. All rights reserved.
//

import UIKit

class QueueNode<T> {
    var next : QueueNode?{
        didSet{
            next?.previus = self
        }
    }
    weak var previus : QueueNode?
    var value : T
    
    init(value:T) {
        self.value = value
    }
}

class TPQueue<T> {
    
    /// When adding new node on queue it is add on top of queue, so he bacome new last node, when we remove from queue it is remove from bottum so first node is deleted and his next node become new first node.
    var first : QueueNode<T>?
    var last : QueueNode<T>?
    var count = 0
    
    func clear(){
        first = nil
        last = nil
        count = 0
    }
    
    /// Check if there is any element in queue
    /// running time: O(1)
    ///
    /// - return: is queue empty

    var isEmpty:Bool{
        get{
            return first == nil
        }
    }
    
    // MARK:
    // MARK: Insert
    
    /// Create new node with value, inserted in queue and make it last object in stack, now previus addes node has next node equel to new added, if queue is empty than new added node is alse first node.
    /// running time: O(1)
    ///
    /// - parameter value:  value to insert in queue
    
    func enqueue(value:T){
    
        let node = QueueNode.init(value: value)
        
        last?.next = node
        
        if (first == nil){
            first = node
        }
        last = node
        count += 1
    }
    
    // MARK:
    // MARK: Delete and search
    
    /// If queue is empty return nil, else return value of first node in queue, and delete this node.
    /// running time: O(1)
    ///
    /// - return:  first node in queue
    func dequeue()->T?{
        
        if first == nil{return nil}
    
        let node = first?.next
        let value = first?.value
        first = node
        if first == nil{
            last = nil
        }
        count -= 1
        return value
    }
    
    /// If queue is empty return nil, else return value of first node in queue.
    /// running time: O(1)
    ///
    /// - return:  first node in queue
    func peek()->T?{
    
        if first == nil{return nil}
        return first!.value
    }
}
