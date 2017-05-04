//
//  Stack.swift
//  swiftTest
//
//  Created by Tomislav Profico on 06/12/16.
//  Copyright © 2016 Tomislav Profico. All rights reserved.
//

import UIKit

class StackNode<T> {
    var next : StackNode?
    
    var value : T
    
    init(value:T) {
        self.value = value
    }
}


class TPStack<T> {
    
    /// Last added node to stack, when adding new node on stack it is add on top of stack, so he bacome new last node, when we remove from stack it is also remove from top so last node is deleted and his next node become new last node.
    var last : StackNode<T>?
    
    var count = 0
    
    /// Check if there is any element in stack
    /// running time: O(1)
    ///
    /// - return: is stack empty
    var isEmpty:Bool{
        get{
            return last == nil
        }
    }
    
    // MARK:
    // MARK: Insert
    
    /// Create new node with value, inserted in stack and make it last object in stack, his next node is previus last
    /// running time: O(1)
    ///
    /// - parameter value:  value to insert in stack
    func push(value:T){
    
        let node = StackNode.init(value: value)
        node.next = self.last
        last = node
        count += 1
    }
    
    // MARK:
    // MARK: Search and delete
    
    /// If stack is empty return nil else return last node in stack, and delete this node, new last node on stack is next node of deleted node
    /// running time: O(1)
    ///
    /// - return:  deleted node form stack if exist
    func pop()->T?{
    
        if last == nil{return nil}
        let result = last?.value
        last = last?.next
        count -= 1
        return result
    }
    
    /// Like pop, just do not delete returned node
    /// running time: O(1)
    ///
    /// - return:  last node form stack if exist
    func peek()->T?{
        if last == nil{return nil}
        return last!.value
    }
}
