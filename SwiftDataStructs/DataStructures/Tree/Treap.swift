//
//  Treap.swift
//  swiftTest
//
//  Created by Tomislav Profico on 01/03/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class Treap<T : Comparable>: BinarySearchTree<T> {
    
    // MARK:
    // MARK: Insert
    
    /// Call superclass insert and just in inserted node add random generated key
    /// average running time: O(log(n))
    ///
    /// - parameter value:     value that is inserted
    ///
    /// - returns: node that is creted in inserted in tree
    @discardableResult
    override func insert(value: T) -> BinarySearchTreeNode<T> {
        let node = super.insert(value: value)
        node.key = random()
        checkRotations(node: node)
        return node
    }
    
    /// If node parent in nil return, else check if node key is greater than parent if yes rotate and with new parent call this method.
    ///
    /// - parameter node:     node checked
    fileprivate func checkRotations(node:BinarySearchTreeNode<T>){
        
        guard node.parent != nil else {
            return
        }
        
        var newParent :BinarySearchTreeNode<T>?
        
        if node.key! < node.parent!.key! && node.isRightChild{
            newParent = rotateRightRight(parentNode: node.parent!)
        }else if node.key! < node.parent!.key! && node.isLeftChild{
            newParent = rotateLeftLeft(parentNode: node.parent!)
        }
        
        if newParent != nil{
            checkRotations(node: newParent!)
        }
        
    }
    
    // MARK:
    // MARK: Delete
    
    /// Totaly overide subclass method. Find node to delete if not exist return nil, else if he not contain any children just remove him, else change his key to -1 and rotate utils he become leaf and then delete him
    /// average running time: O(log(n))
    ///
    /// - parameter value:     value that is delted
    ///
    /// - returns: node that is creted in inserted in tree
    override func deleteWithParentReturned(value: T) -> BinarySearchTreeNode<T>? {
        
        let node = select(value: value)
        
        guard node != nil else {
            return nil
        }
        
        if node!.containNoChild{
            removeNodeWithNoChildren(node: node!)
        }else{
            node!.key = -1
            checkRotationDown(node: node!)
        }
        
        return rootNode;
    }
    
    /// If node not contain any children delete him, check roatation and rotate if neded. CAll method until node to deleted is leaf.
    ///
    /// - parameter node:     node checked
    fileprivate func checkRotationDown(node:BinarySearchTreeNode<T>){
        
        guard !node.containNoChild else {
            removeNodeWithNoChildren(node: node)
            return
        }
        
        if node.leftChild == nil || node.rightChild!.key! > node.rightChild!.key!{
            _ = rotateRightRight(parentNode: node)
        }else{
            _ = rotateLeftLeft(parentNode: node)
        }
        
        checkRotationDown(node: node)
    }
    
    // MARK:
    // MARK: Helper

    ///Random generated number used for node key (priority)
    fileprivate func random() -> Int {
        return Int(arc4random_uniform(10000))
    }
    
    
    
}
