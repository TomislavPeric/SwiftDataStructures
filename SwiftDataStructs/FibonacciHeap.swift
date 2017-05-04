//
//  FibonacciHeap.swift
//  swiftTest
//
//  Created by Tomislav Profico on 13/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class FibonacciHeapNode<T : Equatable>{
    
    var key:T
    var isMark:Bool
    var rank:Int
    
    var child : FibonacciHeapNode<T>?{
        didSet{
            child?.parent = self
        }
    }
    weak var parent : FibonacciHeapNode<T>?
    
    weak var prev : FibonacciHeapNode<T>?
    
    var next : FibonacciHeapNode<T>?{
        didSet{
            next?.prev = self
            next?.parent = self.parent
        }
    }
    
    init(key:T,isMark:Bool) {
        self.key = key
        self.isMark = isMark
        rank = 0
    }
}

/// Advantages from Heap:
/// - linear insertation time
/// - linear union time
/// - linear decrease key time
/// - good if number of extract min and delete operation are small in compere to other operations
class FibonacciHeap<T : Equatable & Hashable>{
    
    // minElement (or Max) in tree root
    fileprivate var firstToExtractElement:FibonacciHeapNode<T>?
    
    // number of element in heap
    fileprivate var size:Int
    
    // track every element in heap so we can raplace his value in O(1) time
    fileprivate var mapTracking : [T:FibonacciHeapNode<T>]
    
    /// We need order function so we can know does heap is MIN-HEAP or MAX-HEAP. Notice that T not need to be inhereted from Comperable, this is because of exist of this order function, so we have control which element is root (MIN or MAX), and which element is extracted first.
    var orderFunction : (T,T)->Bool
    
    /// Custom constructor so we can send order function we want
    ///
    /// - parameter orderFunction:  order function
    init(orderFunction:@escaping (T,T)->Bool) {
        size = 0
        self.orderFunction = orderFunction
        mapTracking = [:]
    }
    
    /// Check if there is any element in heap
    /// running time: O(1)
    ///
    /// - return: is heap empty
    func isEmpty()->Bool{
        return size == 0
    }
    
    /// delete all heap
    /// running time: O(1)
    func clear(){
        firstToExtractElement = nil
        size = 0
        mapTracking = [:]
    }
    
    // MARK:
    // MARK: Insert
    
    /// Insert new element and set in in root array, chack if this node is first to extract if yes set him as firstToExtract pointer
    /// running time: O(1)
    ///
    /// - parametar value: value that we want insert to heap
    func insert(value:T){
        let node = FibonacciHeapNode<T>.init(key: value, isMark: false)
        mapTracking[value] = node
        insertNodeInRoot(node: node)
        size += 1
    }
    
    // MARK:
    // MARK: extract
    
    /// Extract element for heap.
    /// running time: O(log(n))
    ///
    /// - return: extracted element (previus firstToExtractElement) of heap
    func extract()->T?{
        
        if firstToExtractElement == nil{
            return nil
        }else if firstToExtractElement?.next == nil && firstToExtractElement!.child == nil{
            let value = firstToExtractElement!.key;
            clear()
            return value
        }
        let value = firstToExtractElement?.key
        
        addFirstToExtractNodeChildrenToRoot()
        
        var node = firstToExtractElement!.next!
        removeNode(node: firstToExtractElement!)
        size -= 1
        
       
        var map : [Int:FibonacciHeapNode<T>] = [:]
        firstToExtractElement = checkRank(node:node, map: &map, newFrontNode: node,firstRootNode: &node)
        if firstToExtractElement != nil && firstToExtractElement?.prev != nil{
            exchangeTwoNodes(firstNode: node, secondNode: firstToExtractElement!)
        }
        
        mapTracking[value!] = nil
        return value
    }
    
    /// When extracting node, we balance tree in such way that no two root node has same rank (number of direct child). This is recursivley call method that pass every node in heap root and if there is two node with same rank it connect this two in one and continue with process with this node.
    ///
    /// - parameter node: node to be checked
    /// - parameter map: map store nodes by rank
    /// - parameter newFrontNode: In this process we must keep track which of node will be new first to extract node
    /// - parameter firstRootNode: We also track which of node is currently first in root, this is needed because previus first node in root was deleted
    ///
    /// - return: node that will be new first to extract node
    var ii = 0
    fileprivate func checkRank(node:FibonacciHeapNode<T>?,map:inout [Int:FibonacciHeapNode<T>],newFrontNode:FibonacciHeapNode<T>,firstRootNode:inout FibonacciHeapNode<T>)->FibonacciHeapNode<T>{
        ii += 1
        
        if ii > 2500{
            ii = 0
            return newFrontNode
        }
        
        guard node != nil else{
            ii = 0
            return newFrontNode
        }
        
        if let oldNode = map[node!.rank]{
            if oldNode === firstRootNode{
                firstRootNode = oldNode.next!
            }
            let newNode = connectNodes(firstNode: oldNode, secondNode: node!,map: &map)
            let newFr = orderFunction(newFrontNode.key,newNode.key) ? newFrontNode : newNode
            firstRootNode = newNode.prev == nil ? newNode : firstRootNode
            return checkRank(node: newNode, map: &map, newFrontNode: newFr, firstRootNode: &firstRootNode)
        }else{
            map[node!.rank] = node
            var newFr : FibonacciHeapNode<T>
            if node!.next == nil{
                newFr = newFrontNode
            }else{
                newFr = orderFunction(newFrontNode.key,node!.next!.key) ? newFrontNode : node!.next!
            }
            return checkRank(node: node!.next, map: &map, newFrontNode: newFr, firstRootNode: &firstRootNode)
        }
    }
    
    /// helper method, for removing node. connect two node that is in root. first check does this two node need to be excange and then concat two node
    /// running time: O(1)
    ///
    /// - parameter firstNode: firstNode to be conected
    /// - parameter firstNode: secondNode to be conected
    fileprivate func connectNodes(firstNode:FibonacciHeapNode<T>,secondNode:FibonacciHeapNode<T>,map:inout [Int:FibonacciHeapNode<T>])->FibonacciHeapNode<T>{
        
        if orderFunction(firstNode.key,secondNode.key) == true{
            
            map[firstNode.rank] = nil
            
            exchangeTwoNodes(firstNode: firstNode, secondNode: secondNode)
            concatTwoNode(newParent: firstNode, newChild: secondNode)
            
            return firstNode
        }else{
            //print(secondNode)
            map[secondNode.rank] = nil
            
            concatTwoNode(newParent: secondNode, newChild: firstNode)
            
            return secondNode
        }
    }
    
    // MARK:
    // MARK: replace
    
    /// Replace value in heap. Get node store in hash map, change his value, if this node should go up just cut him and put in root list, and mark his parent if he is unmarked, if he is mark cut him to and go up checking his parent.
    /// running time: O(1)
    ///
    /// - parameter oldItem: value we want change
    /// - parameter newItem: new value of change node
    func increasePriority(oldItem:T,newItem:T){
    
        let node = mapTracking[oldItem]
        
        guard node != nil else {
            return
        }
        node!.key = newItem
        if orderFunction(newItem,oldItem) == true{
            
            if node?.parent == nil {
                checkSetNewFirstToExtract(node:node!)
                return
            }
            
            if !orderFunction(node!.parent!.key,newItem){
                let parent = node!.parent
                removeNode(node: node!)
                insertNodeInRoot(node: node!)
                parent?.rank -= 1
                if parent!.isMark == false && parent!.parent != nil{
                    parent!.isMark = true
                }else if parent!.parent != nil{
                    cutUp(node: parent)
                }
            }
        }else{
            assert(false, "Not allow decreasing priority")
        }
    }
    
    // MARK:
    // MARK: private helpers
    
    /// Insert node in root of heap, check with order function if this node is next nde to extract.
    /// running time: O(1)
    ///
    /// - parameter node: node to insert to root
    fileprivate func insertNodeInRoot(node:FibonacciHeapNode<T>){
        
        guard firstToExtractElement != nil else {
            firstToExtractElement = node
            return
        }
    
        if !orderFunction(firstToExtractElement!.key,node.key){
            node.next = firstToExtractElement
            firstToExtractElement = node
        }else{
            node.next = firstToExtractElement!.next
            firstToExtractElement!.next = node
        }
    
    }
    
    /// If node have no parent we check with order function is he be new node to extract if yes delete him and insert in front
    /// running time: O(1)
    ///
    /// - parameter node: node to insert to root
    fileprivate func checkSetNewFirstToExtract(node:FibonacciHeapNode<T>){
    
        if !orderFunction(firstToExtractElement!.key,node.key) && node !== firstToExtractElement{
            removeNode(node: node)
            insertNodeInRoot(node: node)
        }
    }
    
    /// Cut node if he is mark from tree, and set him in root, repeat this with his parent
    /// running time: O(1)
    ///
    /// - parameter node: node to be cut from heap
    fileprivate func cutUp(node:FibonacciHeapNode<T>?){
        
        guard node != nil else {
            return
        }
        
        guard node!.isMark == true else {
            return
        }
        
        let parent = node!.parent
        removeNode(node: node!)
        insertNodeInRoot(node: node!)
        node!.isMark = false
        parent?.rank -= 1
        cutUp(node: parent)
        
    }
    
    /// Excange two node that have same parent
    /// running time: O(1)
    ///
    /// - parameter firstNode: firstNode to be excange
    /// - parameter secondNode: secondNode to be excange
    fileprivate func exchangeTwoNodes(firstNode:FibonacciHeapNode<T>,secondNode:FibonacciHeapNode<T>){
        
        guard firstNode !== secondNode else {
            return
        }
    
        if firstNode.next === secondNode{
            secondNode.prev = nil
            firstNode.prev?.next = secondNode
            firstNode.next = secondNode.next
            secondNode.next = firstNode
        }else{
            let second = firstNode.next;
            let null = firstNode.prev
            firstNode.next = secondNode.next
            secondNode.prev?.next = firstNode
            secondNode.prev = null
            null?.next = secondNode
            secondNode.next = second
        }
    }
    
    /// When remove parent we need to cut his children and add them to root
    fileprivate func addFirstToExtractNodeChildrenToRoot(){
    
        guard firstToExtractElement!.child != nil else {
            return
        }
        
        var child = firstToExtractElement!.child;
        var array = [child]
        while child != nil {
            let nextStored = child!.next
            removeNode(node: child!)
            child = nextStored
            array.append(child)
        }
        
        for node in array{
            if node != nil{
                node!.next = firstToExtractElement!.next
                firstToExtractElement!.next = node
            }
        }
    }
    
    /// Remove node from heap
    ///
    /// - parameter node: node to be removed
    fileprivate func removeNode(node: FibonacciHeapNode<T>){
    
        if node.parent?.child === node{
            node.parent?.child = node.next
        }
        
        node.prev?.next = node.next
        if (node.prev == nil){
            node.next?.prev = nil
        }
        node.prev = nil
        node.next = nil
        
        node.parent = nil
    }
    
    /// concat two node, one is added as child of other
    ///
    /// - parameter newParent: newParent
    /// - parameter newChild: node that is added as child of new parent
    fileprivate func concatTwoNode(newParent:FibonacciHeapNode<T>,newChild:FibonacciHeapNode<T>){
    
        removeNode(node: newChild)
        
        if newParent.rank == 0{
            newParent.child = newChild
        }else{
            let child = newParent.child
            newParent.child = newChild
            newChild.next = child
        }
        newParent.rank += 1
    }
    
    // MARK:
    // MARK: search
   
    /// Just look at root element in heap and return firstToExtractElement
    /// O(1)
    ///
    /// - return: extracted element (firstToExtractElement) of heap
    func peek() -> T? {
        return firstToExtractElement?.key
    }
    
}
