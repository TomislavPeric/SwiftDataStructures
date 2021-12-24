//
//  QueueWithMax.swift
//  swiftTest
//
//  Created by Tomislav Profico on 18/04/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class QueueWithMax<T : Comparable> {

    fileprivate var deque : Dequeue<T>
    fileprivate var queue : TPQueue<T>
    
    init() {
        deque = Dequeue<T>()
        queue = TPQueue<T>()
    }
    
    var count : Int{
        get{
            return queue.count
        }
    }
    
    func enqueue(value : T){
        queue.enqueue(value: value)
        /*while deque.isEmpty == false && deque.peekFromEnd()! < value{
            _ = deque.dequeueFromEnd()
        }
        deque.enqueue(value: value)*/
    }
    
    func dequeue()->T?{
        
        let front = queue.dequeue()
        
        /*if front == deque.peek(){
            _ = deque.dequeue()
        }*/
        return front
    }
    
    func max()->T?{
        return deque.peek()
    }
    
}
