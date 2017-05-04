//
//  SkipList.swift
//  swiftTest
//
//  Created by Tomislav Profico on 28/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class SkipListNode<K : Comparable>{
    
    var value:K?
    
    var right: SkipListNode<K>?{
        didSet{
            right?.left = self
        }
    }
    var left: SkipListNode<K>?
    
    var top: SkipListNode<K>?{
        didSet{
            top?.bottum = self
        }
    }
    var bottum: SkipListNode<K>?
    
    init(value:K) {
        self.value = value
    }
    
    init() {
        
    }
}

class SkipList<K : Comparable> {
    
    //node at front and top of list
    fileprivate var startTop : SkipListNode<K>
    
    //node at front and bottum of list, all values is contains by this node and a node is order
    fileprivate var startBottum : SkipListNode<K>
    
    //final node at bottum of list, need this so we can access max value
    fileprivate var endBottum : SkipListNode<K>?
    
    // height of list
    fileprivate var currentLevel = 0
    
    init() {
        let node = SkipListNode<K>.init()
        startTop = node
        startBottum = node
    }
    
    //This is randomize data structure, there is 50 percent chance that return true
    fileprivate func coinFlip() -> Bool {
        return arc4random_uniform(2) == 1
    }
    
    // MARK:
    // MARK: Search
    
    /// Search for value
    /// Running time: O(log(n))
    ///
    /// - parameter value: value that is searched
    /// - return: is value found
    func search(value:K)->Bool{
    
        return search(value: value, currentNode:startTop) != nil
    }
    
    /// Search for value. Start on top left and if current value is found return node on bottum list with found value. Else if right value is less then searched value go right and continue process with right node, else if bottum is nil value not exist and return nil, and else go buttom in tree and continue process with bottum node.
    /// Running time: O(log(n))
    ///
    /// - parameter value: value that is searched
    /// - parameter currentNode: current node that we checked
    ///
    /// - return: found node if exist
    fileprivate func search(value:K, currentNode:SkipListNode<K>?)->SkipListNode<K>?{
    
        guard currentNode != nil else {
            return nil
        }
        
        if currentNode!.value != nil && currentNode!.value! == value && currentNode!.bottum == nil{
            return currentNode
        }
        
        if currentNode!.right != nil && currentNode!.right!.value! <= value{
            return search(value: value, currentNode: currentNode!.right)
        }
        
        if currentNode!.bottum == nil{
            return nil
        }
        
        return search(value: value, currentNode: currentNode!.bottum)
    
    }
    
    // MARK:
    // MARK: Insert
    
    /// insert value
    /// Running time: O(log(n))
    ///
    /// - parameter value: value that is inserted
    func insert(value:K){
        insert(value: value, currentNode: startTop)
    }
    
    /// insert value. If current node right child is not nil and his value ia smaller or equel of inserted value, go right on tree. else if bottum node is not nil go down in tree, else insert new node after current node, and check with randomize function if inserted this value up in tree.
    /// Running time: O(log(n))
    ///
    /// - parameter value: value that is inserted
    /// - parameter currentNode: current node that we checked
    fileprivate func insert(value:K, currentNode:SkipListNode<K>?){
        
        if currentNode!.right != nil && currentNode!.right!.value! <= value{
            insert(value: value, currentNode: currentNode!.right)
        }else if currentNode!.bottum != nil{
            insert(value: value, currentNode: currentNode!.bottum)
        }else{
            let node = SkipListNode<K>.init(value: value)
            node.right = currentNode?.right
            currentNode!.right = node
            if node.right == nil{
                endBottum = node
            }
            insertUp(currentNode: node, level:0)
        }
    }
    
    /// Check with randomize function if inserted this value up in tree.
    ///
    /// - parameter currentNode: current node that we checked
    /// - parameter lavel: height of current node
    fileprivate func insertUp(currentNode:SkipListNode<K>, level:Int){
    
        if coinFlip() == true{
            if level == currentLevel{
                createLavelUp()
            }
            let node = insertUpHelper(currentNode: currentNode)
            insertUp(currentNode: node, level: level + 1)
        }
    }
    
    /// Insert on node top node with same value.
    ///
    /// - parameter currentNode: current node that we checked
    /// - parameter currentNode: inserted node
    fileprivate func insertUpHelper(currentNode:SkipListNode<K>)->SkipListNode<K>{
        var node = currentNode
        
        while node.top == nil {
            node = node.left!
        }
        node = node.top!
        
        let newNode = SkipListNode<K>.init(value: currentNode.value!)
        currentNode.top = newNode
        newNode.right = node.right
        node.right = newNode
        return newNode
    }
    
    /// Create new level on top of list.
    fileprivate func createLavelUp(){
        let node = SkipListNode<K>.init()
        startTop.top = node
        startTop = node
        currentLevel += 1
    }
    
    /// Min value in tree. Just first value at bottum list in tree.
    ///
    /// - return : min value in tree
    func minValue()->K?{
        return startBottum.right?.value
    }
    
    /// Max value in tree. Just last value at bottum list in tree.
    ///
    /// - return : max value in tree
    func maxValue() -> K? {
        return endBottum?.value
    }
    
    /// return max value in tree and remove node with max value.
    ///
    /// - return : max value in tree
    func extractMin() -> K?{
    
        let min = minValue()
        if startBottum.right != nil{
            removeNode(node: startBottum.right!, level: 0)
        }
        return min
    }
    
    /// return min value in tree and remove node with min value.
    ///
    /// - return : min value in tree
    func extractMax() -> K?{
        
        let max = maxValue()
        if endBottum != nil{
            removeNode(node: endBottum!, level: 0)
        }
        return max
    }
    
    /// remove value
    ///
    /// - return : if removed return true else false (not exist that value in tree)
    @discardableResult
    func remove(value:K)->Bool{
    
        let node = search(value: value, currentNode: startTop)
        if node == nil{
            return false
        }
        removeNode(node: node!, level: 0)
        return true;
    }
    
    /// remove node from tree, removing all top node and connceting his left and right child
    ///
    /// - parameter node: node removing
    /// - parameter level: height of current node
    fileprivate func removeNode(node:SkipListNode<K>, level:Int){
        
        guard node.left != nil else {
            return
        }
        
        let left = node.left!
        left.right = node.right
        if left.right == nil && level == 0{
            endBottum = left
        }
        
        if node.top != nil{
            removeNode(node: node.top!, level: level + 1)
        }
        node.top = nil
        node.bottum = nil
    }
    
    
    /// update node with old value with new value. First find node with old value, if not exist return false, else if this node will stay in same place in list then just replace it value and value of top nodes, else remove node. and search from top of list his next position.
    ///
    /// - parameter lastValue: value to update
    /// - parameter newValue: new value of updated node
    ///
    /// - return: is node updated
    @discardableResult
    func update(lastValue:K,newValue:K)->Bool{
        
        guard lastValue != newValue else {
            return true
        }
        
       let node = search(value: lastValue, currentNode: startTop)
        
        guard node != nil else {
            return false
        }
        
        if (lastValue > newValue && node!.left!.value != nil && node!.left!.value! > newValue) || (lastValue < newValue && node!.right != nil && node!.right!.value! < newValue){
        
            removeNode(node: node!, level: 0)
            
            let previusNode = findNodeThatNewValueFitNext(newValue: newValue, currentNode: startTop)
            
            guard previusNode != nil else {
                return false
            }
            
            let node = SkipListNode<K>.init(value: newValue)
            node.right = previusNode!.right
            previusNode!.right = node
            insertUp(currentNode: node, level: 0)
        
        }else{
            
            node!.value = newValue
            var top = node
            while let n = top!.top{
                n.value = newValue
                top = n
            }
        }
    
        return true
    }
    
    /// Find node that will be previus node of node with newValue
    ///
    /// - parameter currentNode: current node we checked
    /// - parameter newValue: new value of updated node
    ///
    /// - return: node who will become previus node of new node.
    fileprivate func findNodeThatNewValueFitNext(newValue:K, currentNode:SkipListNode<K>)->SkipListNode<K>?{
    
        if currentNode.value == nil && currentNode.bottum == nil{
            return currentNode
        }else if currentNode.value == nil && currentNode.right != nil && currentNode.right!.value! <= newValue{
            return findNodeThatNewValueFitNext(newValue: newValue, currentNode: currentNode.right!)
        }else if currentNode.value == nil{
            return findNodeThatNewValueFitNext(newValue: newValue, currentNode: currentNode.bottum!)
        }
        
        if currentNode.value! == newValue && currentNode.bottum == nil{
            return currentNode
        }else if currentNode.value! == newValue{
            return findNodeThatNewValueFitNext(newValue: newValue, currentNode: currentNode.bottum!)
        }
        
        if currentNode.right != nil && currentNode.right!.value! <= newValue{
            return findNodeThatNewValueFitNext(newValue: newValue, currentNode: currentNode.right!)
        }else if currentNode.bottum == nil{
            return currentNode
        }else{
            return findNodeThatNewValueFitNext(newValue: newValue, currentNode: currentNode.bottum!)
        }
    }

}

class SkipListAscendingIterator<T : Comparable> : Iterator{
    
    let list: SkipList<T>
    var node: SkipListNode<T>?
    
    init(list:SkipList<T>) {
        self.list = list
        node = list.startBottum.right
    }
    
    func hasNext() -> Bool {
        return node != nil && node!.value != nil
    }
    
    func next() -> Any? {
        let value = node
        node = node!.right
        return value!.value
    }
    
    func hasPrevius()->Bool{
        return false
    }
    
    func previus()->Any?{
        return nil;
    }
}

class SkipListDescendingIterator<T : Comparable> : Iterator{
    
    let list: SkipList<T>
    var node: SkipListNode<T>?
    
    init(list:SkipList<T>) {
        self.list = list
        node = list.endBottum
    }
    
    func hasNext() -> Bool {
        return false
    }
    
    func next() -> Any? {
        return nil
    }
    
    func hasPrevius()->Bool{
        return node != nil && node!.value != nil
    }
    
    func previus()->Any?{
        let value = node
        node = node!.left
        return value!.value!
    }
}
