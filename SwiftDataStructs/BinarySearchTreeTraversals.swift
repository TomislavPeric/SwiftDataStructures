//
//  BinarySearchTreeTraversals.swift
//  swiftTest
//
//  Created by Tomislav Profico on 01/03/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class BinarySearchTreeTraversal<T : Comparable>{

    fileprivate var tree : BinarySearchTree<T>
    
    init(tree:BinarySearchTree<T>) {
        self.tree = tree
    }
    
    func traverse(){
        
    }
}

class BinarySearchTreeRecursiveTraversal<T : Comparable> : BinarySearchTreeTraversal<T>{
    
    var visitor:Visitor<T>
    
    init(tree:BinarySearchTree<T>,visitor:Visitor<T>) {
        self.visitor = visitor
        super.init(tree: tree)
        traverse()
    }
}

class BinarySearchTreeInOrderIterateTraversal<T : Comparable> : BinarySearchTreeTraversal<T>, Iterator {

    fileprivate var stack : TPStack<BinarySearchTreeNode<T>>
    fileprivate var root : BinarySearchTreeNode<T>?
    
    override init(tree:BinarySearchTree<T>) {
        stack = TPStack<BinarySearchTreeNode<T>>()
        super.init(tree: tree)
        root = tree.rootNode
    }
    
    func hasNext() -> Bool {
        return root != nil || !stack.isEmpty
    }
    
    func hasPrevius() -> Bool {
        return false
    }
    
    func next() -> Any? {
        
        if root != nil{
            
            while root != nil {
                stack.push(value: root!)
                root = root!.leftChild
            }
            return next()
        }else{
            root = stack.pop()!
            let value = root!.value
            root = root!.rightChild
            return value
        }
    }
    
    func previus() -> Any? {
        return nil
    }
}

class BinarySearchTreePostOrderIterateTraversal<T : Comparable> : BinarySearchTreeTraversal<T>, Iterator {
    
    fileprivate var stack1 : TPStack<BinarySearchTreeNode<T>>
    fileprivate var stack2 : TPStack<BinarySearchTreeNode<T>>
    
    override init(tree:BinarySearchTree<T>) {
        stack1 = TPStack<BinarySearchTreeNode<T>>()
        stack2 = TPStack<BinarySearchTreeNode<T>>()
        super.init(tree: tree)
        
        guard tree.rootNode != nil else {
            return
        }
        
        let root = tree.rootNode
        stack1.push(value: root!)
        while !stack1.isEmpty {
            let node = stack1.pop()
            if let lNode = node!.leftChild{
                stack1.push(value: lNode)
            }
            if let rNode = node!.rightChild{
                stack1.push(value: rNode)
            }
            
            stack2.push(value: node!)
        }
    }
    
    func hasNext() -> Bool {
        return !stack2.isEmpty
    }
    
    func hasPrevius() -> Bool {
        return false
    }
    
    func next() -> Any? {
        return stack2.pop()!.value
    }
    
    func previus() -> Any? {
        return nil
    }
}

class BinarySearchTreePreOrderIterateTraversal<T : Comparable> : BinarySearchTreeTraversal<T>, Iterator {
    
    fileprivate var stack : TPStack<BinarySearchTreeNode<T>>
    
    override init(tree:BinarySearchTree<T>) {
        stack = TPStack<BinarySearchTreeNode<T>>()
        super.init(tree: tree)
        
        guard tree.rootNode != nil else {
            return
        }
        
        stack.push(value: tree.rootNode!)
    }
    
    func hasNext() -> Bool {
        return !stack.isEmpty
    }
    
    func hasPrevius() -> Bool {
        return false
    }
    
    func next() -> Any? {
        
        let node = stack.pop()
        
        if let rNode = node!.rightChild{
            stack.push(value: rNode)
        }
        
        if let lNode = node!.leftChild{
            stack.push(value: lNode)
        }
        
        return node!.value
    }
    
    func previus() -> Any? {
        return nil
    }
}

class BinarySearchTreeLevelOrderIterateTraversal<T : Comparable> : BinarySearchTreeTraversal<T>, Iterator {
    
    fileprivate var queue : TPQueue<BinarySearchTreeNode<T>>
    
    override init(tree:BinarySearchTree<T>) {
        queue = TPQueue<BinarySearchTreeNode<T>>()
        super.init(tree: tree)
        
        guard tree.rootNode != nil else {
            return
        }
        
        queue.enqueue(value: tree.rootNode!)
    }
    
    func hasNext() -> Bool {
        return !queue.isEmpty
    }
    
    func hasPrevius() -> Bool {
        return false
    }
    
    func next() -> Any? {
        
        let node = queue.dequeue()
        
        if let lNode = node!.leftChild{
            queue.enqueue(value: lNode)
        }
        
        if let rNode = node!.rightChild{
            queue.enqueue(value: rNode)
        }
        
        return node!.value
    }
    
    func previus() -> Any? {
        return nil
    }
}

class BinarySearchTreeInOrderRecursiveTraversal<T : Comparable> : BinarySearchTreeRecursiveTraversal<T> {

    override func traverse(){
        guard tree.rootNode != nil else {
            return
        }
        traverse(node: tree.rootNode)
    }
    
    func traverse(node:BinarySearchTreeNode<T>?){
    
        guard node != nil else {
            return
        }
        traverse(node: node!.leftChild)
        visitor.visit(object: node!.value)
        traverse(node: node!.rightChild)
    }
}

class BinarySearchTreePreOrderRecursiveTraversal<T : Comparable> : BinarySearchTreeRecursiveTraversal<T>{
    
    override func traverse(){
        guard tree.rootNode != nil else {
            return
        }
        
        
        traverse(node: tree.rootNode)
    }
    
    func traverse(node:BinarySearchTreeNode<T>?){
        
        guard node != nil else {
            return
        }
        
        visitor.visit(object: node!.value)
        
        traverse(node: node!.leftChild)
        traverse(node: node!.rightChild)
    }
    
}

class BinarySearchTreePostOrderRecursiveTraversal<T : Comparable> : BinarySearchTreeRecursiveTraversal<T>{
    
    override func traverse(){
        guard tree.rootNode != nil else {
            return
        }
        
        traverse(node: tree.rootNode)
    }
    
    func traverse(node:BinarySearchTreeNode<T>?){
        
        guard node != nil else {
            return
        }
        
        traverse(node: node!.leftChild)
        traverse(node: node!.rightChild)
        
        visitor.visit(object: node!.value)
    }
}
