//
//  Dequeue.swift
//  swiftTest
//
//  Created by Tomislav Profico on 18/04/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class Dequeue<T>: TPQueue<T>{
    
    func enqueueToStart(value:T){
        
        let node = QueueNode.init(value: value)
        if first == nil{
            first = node
            last = node
        }else{
            let helper = first
            first = node
            first!.next = helper
        }
        count += 1
    }
    
    func dequeueFromEnd()->T?{
        
        if last == nil{return nil}
        
        let node = last?.previus
        let value = last?.value
        if node == nil{
            first = nil
            last = nil
        }else{
            last = node
        }
        count -= 1
        return value
    }
    
    func peekFromEnd()->T?{
        
        return last?.value
    }
}
