//
//  SplayTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 16/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit
import ObjectiveC



/// This tree is not fully balanced but last searched and inserted values are in top so accesing them again is fast. This is good for caching application.
class SplayTree<T: Comparable>: BinarySearchTree<T> {
    
    
    
    
    // MARK:
    // MARK: Insert
    
    /// Call superclass insert and now splay on inserted node
    /// average running time: O(log(n))
    ///
    /// - parameter value:     value that is inserted
    ///
    /// - returns: node that is creted in inserted in tree
    @discardableResult
    override func insert(value: T) -> BinarySearchTreeNode<T> {
        
        let node = super.insert(value: value)
        node.leftSubtreeHeight = 0
        node.numberOfChilds = 1
        splay(node: node)
        return node
    }
    
    // MARK:
    // MARK: Select
    
    /// Override superclass method completly, because now if fe not found searched value, we splay last node that is traverse before geting nil. If we found node we just splay. This method is call also in delete and extract min and extract max so we do not need override those methods
    /// average running time: O(log(n))
    ///
    /// - parameter value: value that we want search
    ///
    /// - returns: node that is selected in tree
    override func select(value: T) -> BinarySearchTreeNode<T>? {
        
        var newNode = rootNode
        var lastSelected : BinarySearchTreeNode<T>?
        while newNode != nil {
            if newNode!.value > value{
                lastSelected = newNode
                newNode = newNode!.leftChild
            }else if newNode!.value < value{
                lastSelected = newNode
                newNode = newNode!.rightChild
            }else{
                splay(node: newNode!)
                return newNode
            }
        }
        
        if lastSelected != nil{
            splay(node: lastSelected!)
        }
        return nil
    }
    
    // MARK:
    // MARK: Splay
    
    /// Private method that balance splay tree. This tree is not fully balanced but last searched and inserted values are in top so accesing them again is fast. This is good for caching application. This method rotate node until this node become new root
    ///
    /// - parameter node: node that we want to splay
    fileprivate func splay(node:BinarySearchTreeNode<T>){
        
        if node === rootNode{
            return
        }else if node.parent === rootNode && node.isLeftChild{
            let p = super.rotateLeftLeft(parentNode: node.parent!)
            checkHeights(newParent: p)
        }else if node.parent === rootNode && node.isRightChild{
            let p = super.rotateRightRight(parentNode: node.parent!)
            checkHeights(newParent: p)
        }else if node.isRightChild && node.parent!.isLeftChild{
            splay(node: rotateLeftRight(parentNode: node.parent!.parent!))
        }else if node.isLeftChild && node.parent!.isLeftChild{
            splay(node: rotateLeftLeft(parentNode: node.parent!.parent!))
        }else if node.isRightChild && node.parent!.isRightChild{
            splay(node: rotateRightRight(parentNode: node.parent!.parent!))
        }else if node.isLeftChild && node.parent!.isRightChild{
            splay(node: rotateRightLeft(parentNode: node.parent!.parent!))
        }
    }
    
    // MARK:
    // MARK: Rotate
    
    /// We completly overide this method from superclass because rotate leftLeft is now implemented different. Grandchild now becom root of subtree, and grandparent become grandchild. all subtree is rotate around previus root of subtree.
    ///
    /// - parameter parentNode: parentNode we want rotate
    ///
    /// - return: new subtree parent
    override func rotateLeftLeft(parentNode: BinarySearchTreeNode<T>) -> BinarySearchTreeNode<T> {
        
        let child = parentNode.leftChild
        let grandChild = child!.leftChild
        
        if parentNode === rootNode{
            rootNode = grandChild
        }else if parentNode.isLeftChild{
            parentNode.parent!.leftChild = grandChild
        }else{
            parentNode.parent!.rightChild = grandChild
        }
        child!.leftChild = grandChild!.rightChild
        grandChild!.rightChild = child!
        parentNode.leftChild = child!.rightChild
        child!.rightChild = parentNode
        
        parentNode.leftSubtreeHeight = max(parentNode.leftChild?.leftSubtreeHeight! ?? 0, parentNode.rightChild?.leftSubtreeHeight! ?? 0)
        parentNode.leftSubtreeHeight = parentNode.containNoChild == true ? 0 : parentNode.leftSubtreeHeight! + 1
        
        child!.leftSubtreeHeight = max(child!.leftChild?.leftSubtreeHeight! ?? 0, child!.rightChild?.leftSubtreeHeight! ?? 0) + 1
        grandChild!.leftSubtreeHeight = max(grandChild!.leftChild?.leftSubtreeHeight! ?? 0, grandChild!.rightChild?.leftSubtreeHeight! ?? 0) + 1
        
        parentNode.numberOfChilds = (parentNode.leftChild?.numberOfChilds ?? 0) + (parentNode.rightChild?.numberOfChilds ?? 0) + 1
        child!.numberOfChilds = (child!.leftChild?.numberOfChilds ?? 0) + (child!.rightChild?.numberOfChilds ?? 0) + 1
        grandChild!.numberOfChilds = (grandChild!.leftChild?.numberOfChilds ?? 0) + (grandChild!.rightChild?.numberOfChilds ?? 0) + 1
        
        return grandChild!
    }
    
    /// We completly overide this method from superclass because rotate leftLeft is now implemented different. Grandchild now becom root of subtree, and grandparent becom grandchild. all subtree is rotate around previus root of subtree.
    ///
    /// - parameter parentNode: parentNode we want rotate
    ///
    /// - return: new subtree parent
    override func rotateRightRight(parentNode: BinarySearchTreeNode<T>) -> BinarySearchTreeNode<T> {
        
        let child = parentNode.rightChild
        let grandChild = child!.rightChild
        
        if parentNode === rootNode{
            rootNode = grandChild
        }else if parentNode.isLeftChild{
            parentNode.parent!.leftChild = grandChild
        }else{
            parentNode.parent!.rightChild = grandChild
        }
        child!.rightChild = grandChild!.leftChild
        grandChild!.leftChild = child!
        parentNode.rightChild = child!.leftChild
        child!.leftChild = parentNode
        
        parentNode.leftSubtreeHeight = max(parentNode.leftChild?.leftSubtreeHeight! ?? 0, parentNode.rightChild?.leftSubtreeHeight! ?? 0)
        parentNode.leftSubtreeHeight = parentNode.containNoChild == true ? 0 : parentNode.leftSubtreeHeight! + 1
        
        child!.leftSubtreeHeight = max(child!.leftChild?.leftSubtreeHeight! ?? 0, child!.rightChild?.leftSubtreeHeight! ?? 0) + 1
        grandChild!.leftSubtreeHeight = max(grandChild!.leftChild?.leftSubtreeHeight! ?? 0, grandChild!.rightChild?.leftSubtreeHeight! ?? 0) + 1
        
        parentNode.numberOfChilds = (parentNode.leftChild?.numberOfChilds ?? 0) + (parentNode.rightChild?.numberOfChilds ?? 0) + 1
        child!.numberOfChilds = (child!.leftChild?.numberOfChilds ?? 0) + (child!.rightChild?.numberOfChilds ?? 0) + 1
        grandChild!.numberOfChilds = (grandChild!.leftChild?.numberOfChilds ?? 0) + (grandChild!.rightChild?.numberOfChilds ?? 0) + 1
        
        return grandChild!
    }
    
    // overide rotate func just to can check new heights
    override func rotateLeftRight(parentNode: BinarySearchTreeNode<T>) -> BinarySearchTreeNode<T> {
        let newParent = super.rotateLeftRight(parentNode: parentNode)
        checkHeights(newParent: newParent)
        return newParent
    }
    
    // overide rotate func just to can check new heights
    override func rotateRightLeft(parentNode: BinarySearchTreeNode<T>) -> BinarySearchTreeNode<T> {
        let newParent = super.rotateRightLeft(parentNode: parentNode)
        checkHeights(newParent: newParent)
       
       
        
        return newParent
    }
    
    // check new heights
    fileprivate func checkHeights(newParent:BinarySearchTreeNode<T>){
        
        newParent.leftChild?.leftSubtreeHeight = max(newParent.leftChild?.leftChild?.leftSubtreeHeight! ?? 0, newParent.leftChild?.rightChild?.leftSubtreeHeight! ?? 0)
        newParent.leftChild?.leftSubtreeHeight = newParent.leftChild?.containNoChild == true ? 0 : newParent.leftChild!.leftSubtreeHeight! + 1
        
        newParent.rightChild?.leftSubtreeHeight = max(newParent.rightChild?.leftChild?.leftSubtreeHeight! ?? 0, newParent.rightChild?.rightChild?.leftSubtreeHeight! ?? 0)
        newParent.rightChild?.leftSubtreeHeight = newParent.rightChild?.containNoChild == true ? 0 : newParent.rightChild!.leftSubtreeHeight! + 1
        
        newParent.leftSubtreeHeight = max(newParent.leftChild?.leftSubtreeHeight! ?? 0, newParent.rightChild?.leftSubtreeHeight! ?? 0) + 1
        
        if newParent.leftChild != nil{
            newParent.leftChild!.numberOfChilds = (newParent.leftChild!.leftChild?.numberOfChilds ?? 0) + (newParent.leftChild!.rightChild?.numberOfChilds ?? 0) + 1
        }
        
        if newParent.rightChild != nil{
            newParent.rightChild!.numberOfChilds = (newParent.rightChild!.leftChild?.numberOfChilds ?? 0) + (newParent.rightChild!.rightChild?.numberOfChilds ?? 0) + 1
        }
        newParent.numberOfChilds = (newParent.leftChild?.numberOfChilds ?? 0) + (newParent.rightChild?.numberOfChilds ?? 0) + 1
    
    }
    
    // MARK:
    // MARK: Search
    
    func objectAtPosition(position:Int)->T?{
    
        guard rootNode != nil else {
            return nil
        }
        
        return nodeAtPosition(position: position, currentNode: rootNode)?.value
    }
    
    fileprivate func nodeAtPosition(position:Int, currentNode:BinarySearchTreeNode<T>?)->BinarySearchTreeNode<T>?{
        
        guard currentNode != nil else {
            return nil
        }
        
        let currentNodePosition = currentNode!.leftChild?.numberOfChilds ?? 0
        
        if position == currentNodePosition{
            return currentNode
        }
        
        if currentNodePosition > position{
            return nodeAtPosition(position: position, currentNode: currentNode?.leftChild)
        }else{
            return nodeAtPosition(position: position - (currentNodePosition + 1), currentNode: currentNode?.rightChild)
        }
    
    }
    
    // MARK:
    // MARK: Split
    
    
    fileprivate func splitNode(position:Int)->BinarySearchTreeNode<T>?{
        
        let node = nodeAtPosition(position: position, currentNode: rootNode)
        
        guard node != nil else {
            return nil
        }
        
        splay(node: node!)
        let right = node!
        rootNode = node!.leftChild
        node!.leftChild = nil
        node!.numberOfChilds = (node!.leftChild?.numberOfChilds ?? 0) + (node!.rightChild?.numberOfChilds ?? 0) + 1
        size = rootNode?.numberOfChilds ?? 0
        
        return right
    }
    
    func split(position:Int)->SplayTree<T>{
    
        let newRoot = splitNode(position: position)
        let tree = SplayTree<T>.init()
        tree.rootNode = newRoot
        tree.size = 0
        
        if newRoot != nil{
            newRoot!.numberOfChilds = (newRoot!.leftChild?.numberOfChilds ?? 0) + (newRoot!.rightChild?.numberOfChilds ?? 0) + 1
            tree.size = newRoot!.numberOfChilds ?? 0
        }
        
        return tree
    }
    
    // MARK:
    // MARK: Marge
    
    fileprivate func margeRightNode(rightRootNode:BinarySearchTreeNode<T>){
        
        guard rootNode != nil else {
            rootNode = rightRootNode
            rootNode!.numberOfChilds = (rootNode!.leftChild?.numberOfChilds ?? 0) + (rootNode!.rightChild?.numberOfChilds ?? 0) + 1
            return
        }
        
        let node = nodeAtPosition(position: size - 1, currentNode: rootNode)
        
        guard node != nil else {
            return
        }
        
        splay(node: node!)
        node!.rightChild = rightRootNode
        node!.numberOfChilds = (node!.leftChild?.numberOfChilds ?? 0) + (node!.rightChild?.numberOfChilds ?? 0) + 1
    }
    
    fileprivate func margeLeftNode(leftRootNode:BinarySearchTreeNode<T>){
        
        guard rootNode != nil else {
            rootNode = leftRootNode
            rootNode!.numberOfChilds = (rootNode!.leftChild?.numberOfChilds ?? 0) + (rootNode!.rightChild?.numberOfChilds ?? 0) + 1
            return
        }
        
        let node = nodeAtPosition(position: 0, currentNode: rootNode)
        
        guard node != nil else {
            return
        }
        
        splay(node: node!)
        node!.leftChild = leftRootNode
        node!.numberOfChilds = (node!.leftChild?.numberOfChilds ?? 0) + (node!.rightChild?.numberOfChilds ?? 0) + 1
    }
    
    func margeRight(rightTree:SplayTree<T>){
        
        guard rightTree.rootNode != nil else {
            return
        }
        
        margeRightNode(rightRootNode: rightTree.rootNode!)
        size += rightTree.size
    }
    
    func margeLeft(leftTree:SplayTree<T>){
        
        guard leftTree.rootNode != nil else {
            return
        }
        
        margeLeftNode(leftRootNode: leftTree.rootNode!)
        size += leftTree.size
    }
    

}
