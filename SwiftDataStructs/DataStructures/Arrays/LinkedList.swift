//
//  LinkedList.swift
//  swiftTest
//
//  Created by Tomislav Profico on 07/12/16.
//  Copyright © 2016 Tomislav Profico. All rights reserved.
//

import UIKit

class LinkListNode<T> {
    var next : LinkListNode?
    
    var value : T
    
    init(value:T) {
        self.value = value
    }
}

class LinkedList<T> {
    
    /// We have reference to start element of linkList, which has reference to next element...
    var firstNode : LinkListNode<T>?
    
    /// We need equel function so class T not need be inhereted from Comperable class.
    var twoValueEquel : (T,T)->Bool
    
    var size:Int
    
    init(twoValueEquelFunction:@escaping (T,T)->Bool) {
        self.twoValueEquel = twoValueEquelFunction
        self.size = 0
    }
    
    // MARK:
    // MARK: Insert

    /// Insert value at head of link list
    /// Running time: O(1)
    ///
    /// - parameter value:  value need to be inserted on head
    func insertFirst(value:T){
    
        let node = LinkListNode.init(value: value)
        node.next = firstNode
        firstNode = node
        size += 1
    }
    
    /// Insert value after some other value
    /// Running time: O(n) (worst case scenario)
    ///
    /// - parameter value:  value need to be inserted
    /// - parameter after:  value after which is new value inserted
    func insert(value:T,after:T){
    
        let node = find(value: after)
        if node == nil{return}
        let next = node?.next;
        let insertedNode = LinkListNode.init(value: value)
        node!.next = insertedNode
        insertedNode.next = next
        size += 1
    }
    
    /// Check if LinkedList is empty
    var isEmpty:Bool{
        get{
            return firstNode == nil
        }
    }
    
    // MARK:
    // MARK: Delete and search
    
    /// remove first value from linked list
    func removeFirst()->T?{
    
        if firstNode == nil{return nil}
        let l = firstNode!.value
        firstNode = firstNode!.next
        size -= 1
        return l
    }
    
    /// Remove value from LinkedList
    /// Running time: O(n) (worst case scenario)
    ///
    /// - parameter value:  value need to be removed
    func remove(value:T){
        
        var link = firstNode
        var previus :LinkListNode<T>?
        
        while link != nil {
            if twoValueEquel(link!.value,value){
                
                if previus == nil{
                    _ = removeFirst()
                }else{
                    previus!.next = link!.next
                }
                size -= 1
                
            }
            previus = link
            link = link!.next
        }
    }
    
    /// Find value in LinkedList
    /// Running time: O(n) (worst case scenario)
    ///
    /// - parameter value:  value need to be searched
    ///
    /// - return: node which value is equel to searched value, if no such node return nil
    func find(value:T)->LinkListNode<T>?{
    
        var link = firstNode
        
        while link != nil {
            if twoValueEquel(link!.value,value){return link}
            link = link!.next
        }
        
        return nil
    }
}

class LinkedListIterator<T> : Iterator{
    
    let list: LinkedList<T>
    var node: LinkListNode<T>?
    
    init(list:LinkedList<T>) {
        self.list = list
        node = list.firstNode
    }
    
    func hasNext() -> Bool {
        return node != nil
    }
    
    func next() -> Any? {
        let value = node
        node = node!.next
        return value!.value
    }
    
    func hasPrevius()->Bool{
        return false
    }
    
    func previus()->Any?{
        return nil;
    }
}

class LinkedListNodeIterator<T> : Iterator{
    
    let list: LinkedList<T>
    var node: LinkListNode<T>?
    
    init(list:LinkedList<T>) {
        self.list = list
        node = list.firstNode
    }
    
    func hasNext() -> Bool {
        return node != nil
    }
    
    func next() -> Any? {
        let value = node
        node = node!.next
        return value
    }
    
    func hasPrevius()->Bool{
        return false
    }
    
    func previus()->Any?{
        return nil;
    }
}



class DoubleLinkListNode<T>{

    weak var previus : DoubleLinkListNode<T>?
    
    var next : DoubleLinkListNode?{
        didSet{
            next?.previus = self;
        }
    }
    
    var value : T
    
    init(value:T) {
        self.value = value
    }
}

class DoubleEndedLinkedList<T>{
    
    /// firstNode store reference to first node in heap
    /// lastNode store reference to last node in heap
    
    var firstNode : DoubleLinkListNode<T>?{
        didSet{
            if lastNode == nil{
                lastNode = firstNode
            }
        }
    }
    
    var lastNode : DoubleLinkListNode<T>?{
        didSet{
            if firstNode == nil{
                firstNode = lastNode
            }
        }
    }
    
    var size:Int
    
    var twoValueEquel : (T,T)->Bool
    
    init(twoValueEquelFunction:@escaping (T,T)->Bool) {
        self.twoValueEquel = twoValueEquelFunction
        self.size = 0
    }
    
    // MARK:
    // MARK: Insert
    
    /// Insert value at head of linkList
    /// Running time: O(1)
    ///
    /// - parameter value:  value need to be inserted on head
    func insertFirst(value:T){
        
        let node = DoubleLinkListNode.init(value: value)
        node.next = firstNode
        if firstNode != nil{firstNode!.previus = node}
        firstNode = node
        size += 1
    }
    
    /// Insert value at tail of linkList
    /// Running time: O(1)
    ///
    /// - parameter value:  value need to be inserted on tail
    func insertLast(value:T){
        
        let node = DoubleLinkListNode.init(value: value)
        if lastNode == nil{lastNode = node}
        else{
            lastNode!.next = node
            lastNode = node
        }
        size += 1
    }
    
    /// Insert value after some other value
    /// Running time: O(n) (worst case scenario)
    ///
    /// - parameter newValue:  value need to be inserted
    /// - parameter afterValue:  value after which is new value inserted
    ///
    /// - return: is value succesfult inserted (does afterValue exist)
    func insertAfter(afterValue:T, newValue:T)->Bool{
        
        let node = find(value: afterValue)
        let newNode = DoubleLinkListNode.init(value: newValue)
        
        if (node != nil){
            let next = node!.next
            node!.next = newNode
            newNode.next = next
            size += 1
            return true
        }
        
        return false
    }
    
    /// Check if linkedList is empty
    var isEmpty:Bool{
        get{
            return firstNode == nil
        }
    }
    
    // MARK:
    // MARK: Delete and search
    
    /// remove first value from linked list
    /// Running time: O(1)
    func removeFirst()->T?{
        
        if firstNode == nil{return nil}
        let l = firstNode!.value
        firstNode = firstNode!.next
        firstNode?.previus = nil;
        size -= 1
        return l
    }
    
    /// remove last value from linked list
    /// Running time: O(1)
    func removeLast()->T?{
        
        if lastNode == nil{return nil}
        let l = lastNode!.value
        lastNode = lastNode!.previus
        lastNode?.next = nil;
        size -= 1
        return l
    }
    
    /// Remove value from LinkedList
    /// Running time: O(n) (worst case scenario)
    ///
    /// - parameter value:  value need to be removed
    /// - return: is value succesfuly deleted
    func remove(value:T)->Bool{
        
        let node = find(value: value)
        if node == nil{return false}
        else if node === firstNode{
            firstNode = node?.next
            node?.previus?.next = nil;
        }else if node === lastNode{
            lastNode = lastNode?.previus
            node?.previus?.next = nil;
        }else{
            node!.previus?.next = node!.next
        }
        size -= 1
        return true
    }
    
    /// Find value in linked list
    /// Running time: O(n) (worst case scenario)
    ///
    /// - parameter value:  value need to be searched
    ///
    /// - return: node which value is equel to searched value, if no such node return nil
    func find(value:T)->DoubleLinkListNode<T>?{
        
        var link = firstNode
        
        while link != nil {
            if twoValueEquel(link!.value,value){return link}
            link = link!.next
        }
        
        return nil
    }
    
    /// Move value at front of list. First delete node with parameter node, and than insert new node in start
    /// Running time: O(n)
    ///
    /// - parameters value: value wihich node we move to start of tree
    func moveValueToFront(value:T){
    
        _ = remove(value: value)
        insertFirst(value: value)
    }

}

class DoubleEndedLinkedListIterator<T> : Iterator{
    
    let list: DoubleEndedLinkedList<T>
    var node: DoubleLinkListNode<T>?
    var lastNode : DoubleLinkListNode<T>?
    
    init(list:DoubleEndedLinkedList<T>) {
        self.list = list
        node = list.firstNode
        lastNode = list.lastNode
    }
    
    func hasNext() -> Bool {
        return node != nil
    }
    
    func next() -> Any? {
        let value = node
        node = node!.next
        return value!.value
    }
    
    func hasPrevius()->Bool{
        return lastNode != nil
    }
    
    func previus()->Any?{
        let value = lastNode
        lastNode = lastNode!.previus
        return value!.value
    }
}

class DoubleEndedLinkedListNodeIterator<T> : Iterator{
    
    let list: DoubleEndedLinkedList<T>
    var node: DoubleLinkListNode<T>?
    var lastNode : DoubleLinkListNode<T>?
    
    init(list:DoubleEndedLinkedList<T>) {
        self.list = list
        node = list.firstNode
        lastNode = list.lastNode
    }
    
    func hasNext() -> Bool {
        return node != nil
    }
    
    func next() -> Any? {
        let value = node
        node = node!.next
        return value
    }
    
    func hasPrevius()->Bool{
        return lastNode != nil
    }
    
    func previus()->Any?{
        let value = lastNode
        lastNode = lastNode!.previus
        return value
    }
}
