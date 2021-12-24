//
//  CartesianTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 02/03/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class InorderVisitor<T> : Visitor<T>{
    var data : [T] = []
    override func visit(object: T) {
        data.append(object)
    }
}

class CartesianTreeNode<T>{

    var value:T
    
    var size : Int = 1
    
    func resize(){
        size = (leftChild?.size ?? 0) + (rightChild?.size ?? 0) + 1
    }
    
    var leftChild:CartesianTreeNode<T>?{
        didSet{
            leftChild?.parent = self
        }
    }
    
    var rightChild:CartesianTreeNode<T>?{
        didSet{
            rightChild?.parent = self
        }
    }
    
    var parent:CartesianTreeNode<T>?

    init(value:T) {
        self.value = value
    }
    
    var isLeftChild:Bool{
        get{
            return parent != nil && parent!.leftChild === self
        }
    }
    
    var isRightChild:Bool{
        get{
            return parent != nil && parent!.rightChild === self
        }
    }
}

class CartesianTree<T> {
    
    fileprivate var orderFunction : (T,T)->Bool
    
    internal var root : CartesianTreeNode<T>?
    
    var size : Int{
        get{
            return root?.size ?? 0
        }
    }
    
    init(orderFunction:@escaping (T,T)->Bool) {
        self.orderFunction = orderFunction
    }
    
    // MARK:
    // MARK: Build tree
    
    /// build cartesian tree with givin array of data.
    /// running time 0(n)
    ///
    /// parameter array: array of data that is inserted in tree
    func buildTree(array:[T]){
    
        var previus : CartesianTreeNode<T>?
        for object in array{
            previus = add(value: object, previus: previus)
        }
        recalculateAll(node: root)
    }
    
    /// add node to tree private helper method for building tree from array
    ///
    /// parameter value:value added
    /// parameter previus previus node added to tree(most right node)
    /// return node that is created
    fileprivate func add(value:T, previus:CartesianTreeNode<T>?)->CartesianTreeNode<T>{
        
        let node = CartesianTreeNode<T>.init(value: value)
        
        guard previus != nil else {
            root = node
            return root!
        }
        
        previus!.rightChild = node
        
        checkMoveUp(node: node)
        
        return node
    }
    
    /// clear tree
    func clear(){
        root = nil
    }
    
    /// recalculate size of all nodes (post order traversal)
    internal func recalculateAll(node:CartesianTreeNode<T>?){
        
        guard node != nil else {
            return
        }
        
        recalculateAll(node: node!.leftChild)
        recalculateAll(node: node!.rightChild)
        
        node!.resize()
    }
    
    // MARK:
    // MARK: Traversal
    
    /// traverse tree inorder
    ///
    /// parameter node: current node
    /// parameter visitor: visitor
    fileprivate func inorderTraversal(node:CartesianTreeNode<T>?, visitor:Visitor<T>){
        guard node != nil else {
            return
        }
        inorderTraversal(node: node!.leftChild, visitor: visitor)
        visitor.visit(object: node!.value)
        inorderTraversal(node: node!.rightChild, visitor: visitor)
    }
    
    /// traverse tree inorder
    ///
    /// parameter visitor: visitor
    func inorderTraversal(visitor:Visitor<T>){
        inorderTraversal(node: root, visitor: visitor)
    }
    
    /// get array from tree
    func array()->[T]{
        let visitor = InorderVisitor<T>()
        inorderTraversal(visitor: visitor)
        return visitor.data
    }
    
    // MARK:
    // MARK: Append
    
    /// Insert value to tree. merge new created node with tree
    ///
    /// parameter value: value inserted
    func append(value:T){
        let node = CartesianTreeNode<T>.init(value: value)
        root = merge(left: root, right: node)
    }
    
    // MARK:
    // MARK: Merge
    
    /// merge helper. Take root node from left and right tree and merge them in one tree
    ///
    /// parameter left: root node of left tree
    /// parameter right: root node of right tree
    ///
    /// return: root node of merged tree
    internal func merge(left:CartesianTreeNode<T>?, right:CartesianTreeNode<T>?)->CartesianTreeNode<T>?{
    
        guard left != nil else {
            return right
        }
        
        guard right != nil else {
            return left
        }
        
        
        if checkOrdered(v1: left!, v2: right!){
            let newR = merge(left: left!.rightChild, right: right)
            let node = CartesianTreeNode<T>.init(value: left!.value)
            node.leftChild = left!.leftChild
            node.rightChild = newR
            node.resize()
            return node
        }else{
            let newL = merge(left: left, right: right!.leftChild)
            let node = CartesianTreeNode<T>.init(value: right!.value)
            node.leftChild = newL
            node.rightChild = right!.rightChild
            node.resize()
            return node
        }
    }
    
    /// merge self with right tree
    ///
    /// parameter right: right tree
    func mergeRight(right:CartesianTree<T>){
        
        let leftNode = root
        let rightNode = right.root
        
        root = merge(left: leftNode, right: rightNode)
    }
    
    /// merge self with left tree
    ///
    /// parameter left: left tree
    func mergeLeft(left:CartesianTree<T>){
        
        let leftNode = left.root
        let rightNode = root
        
        root = merge(left: leftNode, right: rightNode)
    }
    
    // MARK:
    // MARK: Split
    
    /// Split tree in two tree between position
    ///
    /// parameter position: index from which we split array
    ///
    /// return: tupple with two tree (left and right)
    func split(position:Int)->(leftTree:CartesianTree<T>, rightTree:CartesianTree<T>){
    
        var left : CartesianTreeNode<T>?
        var right : CartesianTreeNode<T>?
        
        split(x: position, currentRoot: root!, leftRoot: &left, rightNode: &right)
        
        let leftTree = CartesianTree<T>.init(orderFunction: orderFunction)
        leftTree.root = left
        
        let rightTree = CartesianTree<T>.init(orderFunction: orderFunction)
        rightTree.root = right
        
        return (leftTree, rightTree)
    }
    
    
    /// Split tree in two tree between position. Helper private method call recurseve
    ///
    /// parameter x: index from which we split array
    /// parameter currentRoot: currentRoot
    /// parameter leftRoot: left Root
    /// parameter rightNode: right Root
    fileprivate func split(x:Int, currentRoot:CartesianTreeNode<T>, leftRoot: inout CartesianTreeNode<T>?, rightNode: inout CartesianTreeNode<T>?){
        
        var newNode : CartesianTreeNode<T>? = nil
        let curIndex = (currentRoot.leftChild?.size ?? 0) + 1
        
        if curIndex <= x{
            if currentRoot.rightChild == nil{
                rightNode = nil
            }else{
                split(x: x - curIndex, currentRoot: currentRoot.rightChild!, leftRoot: &newNode, rightNode: &rightNode)
            }
            leftRoot = CartesianTreeNode<T>.init(value: currentRoot.value)
            leftRoot!.leftChild = currentRoot.leftChild
            leftRoot!.rightChild = newNode
            leftRoot!.resize()
        }else{
            if currentRoot.leftChild == nil{
                leftRoot = nil;
            }else{
                split(x: x, currentRoot: currentRoot.leftChild!, leftRoot: &leftRoot, rightNode: &newNode)
            }
            rightNode = CartesianTreeNode<T>.init(value: currentRoot.value)
            rightNode!.leftChild = newNode
            rightNode!.rightChild = currentRoot.rightChild
            rightNode!.resize()
        }
    }
    
    // MARK:
    // MARK: Insert
    
    /// Insert value in tree at position. split tree between position, merge left with new crated node and merge that with right.
    ///
    /// parameter value: inserted value
    /// parameter position: position in which we insert value
    func insert(value:T, position:Int){
        
        guard root != nil else {
            return
        }
        
        var left : CartesianTreeNode<T>?
        var right : CartesianTreeNode<T>?
        split(x: position, currentRoot: root!, leftRoot: &left, rightNode: &right)
        let newNode = CartesianTreeNode<T>.init(value: value)
        let newLeft = merge(left: left, right: newNode)!
        root = merge(left: newLeft, right: right)
    }
    
    // MARK:
    // MARK: Remove
    
    ///Remove node at position. Split between position, and then split right between 1 and right, and then merge left and new right
    ///
    ///parameter position: position which we deleted
    func remove(position:Int){
        
        guard root != nil else {
            return
        }
        
        var left : CartesianTreeNode<T>?
        var right : CartesianTreeNode<T>?
        var middle : CartesianTreeNode<T>?
        split(x: position, currentRoot: root!, leftRoot: &left, rightNode: &right)
        split(x: 1, currentRoot: right!, leftRoot: &middle, rightNode: &right)
        root = merge(left: left, right: right)
    }
    
    // MARK:
    // MARK: Shift
    
    /// shift array for k position
    ///
    /// parametar k: number of position that we want shift
    func shiftLeft(k:Int){
        
        guard root != nil else {
            return
        }
    
        var left : CartesianTreeNode<T>?
        var right : CartesianTreeNode<T>?
        split(x: k, currentRoot: root!, leftRoot: &left, rightNode: &right)
        root = merge(left: right, right: left)
    }
    
    // MARK:
    // MARK: Helpers
    
    /// With order function check if parent of node is less orhigh then current node, is order function is satisfied return else rotate and check new parent
    ///
    /// - parameter node: node to check
    fileprivate func checkMoveUp(node:CartesianTreeNode<T>){
        guard node.parent != nil else {
            root = node
            return
        }
        
        if checkOrdered(v1: node, v2: node.parent!){
            let node = rotateRight(parentNode: node.parent!)
            if (node != nil){checkMoveUp(node: node!)}
        }
    }
    
    /// Rotate right child to be new parent and old perent to bi his left child. return new parent
    ///
    /// - parameter node: parentNode to parent to rotate
    ///
    /// - return: new parent node
    fileprivate func rotateRight(parentNode:CartesianTreeNode<T>)->CartesianTreeNode<T>?{
        
        let child = parentNode.rightChild
        
        guard child != nil else {
            return nil
        }
        
        replaceParent(parentNode: parentNode, child: child!)
        
        parentNode.rightChild = child!.leftChild
        child!.leftChild = parentNode
        
        return child!
    }
    
    /// Replace parent and child
    ///
    /// - parameter parentNode: parentNode to be replaced
    /// - parameter child: child to be replaced
    fileprivate func replaceParent(parentNode:CartesianTreeNode<T>,child:CartesianTreeNode<T>){
        
        if parentNode === root{
            root = child
            root?.parent = nil
        }else{
            if parentNode.isLeftChild{
                parentNode.parent!.leftChild = child
            }else{
                parentNode.parent!.rightChild = child
            }
        }
    }
    
    // MARK:
    // MARK: Range
    
    /// get array of object in range
    ///
    /// - parameter min: low bound
    /// - parameter max: high bound
    ///
    /// - return: array of data in range
    func range(min:Int, max:Int)->[T]?{
    
        assert(min >= 0)
        assert(max < size)
        assert(min <= max)
        
        guard root != nil else {
            return nil
        }
        var data = [T]()
        range(min: min, max: max, currentNode: root, data:&data, visitor:nil)
        return data
    }
    
    /// visit all data in range
    ///
    /// - parameter min: low bound
    /// - parameter max: high bound
    /// - parameter visitor: visitor object that take action on object
    func visitRange(min:Int, max:Int, visitor:Visitor<T>){
    
        assert(min >= 0)
        assert(max < size)
        assert(min <= max)
        
        guard root != nil else {
            return
        }
        var data = [T]()
        range(min: min, max: max, currentNode: root, data:&data, visitor:visitor)
        
    }
    
    /// helper to find object in range
    ///
    /// - parameter min: low bound
    /// - parameter max: high bound
    /// - parameter visitor: visitor object that take action on object
    /// - parameter data: found nodes
    /// - parameter currentNode: current nod that is checked
    fileprivate func range(min:Int, max:Int, currentNode:CartesianTreeNode<T>?, data: inout [T], visitor:Visitor<T>?){
        
        guard currentNode != nil else {
            return
        }
        
        if currentNode!.leftChild?.size ?? 0 > min{
            range(min: min, max: max, currentNode:currentNode!.leftChild, data:&data, visitor:visitor)
        }
        
        if currentNode!.leftChild?.size ?? 0 >= min && currentNode!.leftChild?.size ?? 0 <= max{
            if (visitor != nil){
                visitor!.visit(object: currentNode!.value)
            }else{
                data.append(currentNode!.value)
            }
        }
        
        if currentNode!.leftChild?.size ?? 0 < max{
            let curIndex = (currentNode?.leftChild?.size ?? 0) + 1
            range(min: min - curIndex, max: max - curIndex, currentNode:currentNode!.rightChild, data:&data, visitor:visitor)
        }
    }
    
    // MARK:
    // MARK: Sort
    
    /// return sort array of cartesian tree
    func sort()->[T]?{
        return visitElementsOrderedHelper(visitor: nil)
    }
    
    /// visit all element in sorted order
    func visitElementsOrdered(visitor:Visitor<T>?){
        _ = visitElementsOrderedHelper(visitor: visitor)
    }
    
    /// helper method that use priority queue to sort data
    ///
    /// parametar visitor: if we have visitor just need to visit all object, else need return sorted array of objects
    ///
    /// return: sorted array of object if there is no visitor
    fileprivate func visitElementsOrderedHelper(visitor:Visitor<T>?)->[T]?{
        
        guard root != nil else {
            return nil
        }
        
        var data : [T] = []
        let priorityQueue = Heap<CartesianTreeNode<T>>.init { (n1, n2) -> Bool in
            self.orderFunction(n1.value,n2.value)
        }
        priorityQueue.insert(value: root!)
        
        while !priorityQueue.isEmpty() {
            let current = priorityQueue.extract()!
            
            if visitor == nil{
                data.append(current.value)
            }else{
                visitor!.visit(object: current.value)
            }
            
            if current.leftChild != nil{
                priorityQueue.insert(value: current.leftChild!)
            }
            
            if current.rightChild != nil{
                priorityQueue.insert(value: current.rightChild!)
            }
        }
        return data
    }
    
    internal func checkOrdered(v1:CartesianTreeNode<T>, v2:CartesianTreeNode<T>)->Bool{
        return self.orderFunction(v1.value ,v2.value)
        //return true
    }
    
    
}
