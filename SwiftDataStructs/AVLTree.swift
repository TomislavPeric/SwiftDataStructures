//
//  AVLTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 02/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

internal extension BinarySearchTreeNode {
    
    ///Checking if node is balance, it is false if difference between height of right and left (or opposite) node subtree is 2 or more
    fileprivate func isNodeBalanced()->Bool{
        return abs(leftSubtreeHeight! - rightSubtreeHeight!) < 2
    }
}

class AVLTree<T:Comparable>: BinarySearchTree<T> {
    
    // MARK:
    // MARK: Insert
    
    /// Call subclass to create and insert node, than set left and right subtree height to zero because new node is alwayes inserted on bottum of tree, and then go up through tree chack if subtree of each node is balanced, if not doing rotatation
    /// running time: O(log(n))
    ///
    /// - parameter value: value that is inserted
    ///
    /// - returns: node that is creted in inserted in tree
    @discardableResult
    override func insert(value: T) -> BinarySearchTreeNode<T> {
        let l = super.insert(value: value)
        l.leftSubtreeHeight = 0
        l.rightSubtreeHeight = 0
        l.numberOfChilds = 1
        goUpAndCheckRotations(node: l, continueUp: false)
        return l
    }
    
    // MARK:
    // MARK: Helpers
    
    /// This private method go up in tree, calculate new right and left subtree height of node parent and then checking if node parent subtree is balanced. If yes then rotate tree, if not go up again. when we come to top of tree we stop end return.
    /// running time: O(log(n))
    ///
    /// - parameter node: node for which parent we calculating left and right height and checking is balance.
    fileprivate func goUpAndCheckRotations(node: BinarySearchTreeNode<T>?, continueUp:Bool){

        if node == nil || node!.isRoot{
            return
        }
        if node!.isLeftChild{
            node!.parent!.leftSubtreeHeight = max(node!.leftSubtreeHeight!, node!.rightSubtreeHeight!) + 1
        }else{
            node!.parent!.rightSubtreeHeight = max(node!.leftSubtreeHeight!, node!.rightSubtreeHeight!) + 1
        }
        
        node!.parent!.numberOfChilds = (node!.parent!.leftChild?.numberOfChilds ?? 0) + (node!.parent!.rightChild?.numberOfChilds ?? 0) + 1
        
        if node!.parent!.isNodeBalanced(){
            goUpAndCheckRotations(node: node!.parent,continueUp: continueUp)
        }else{
            rotateAVLTree(node: node!.parent!,continueUp: continueUp)
        }
    }
    
    /// This private method first check which of 4 posible rotation we will use depending on node chil and grandchild, and also depending of balancing factor of node and his child, then for tree rotated node recalculate heights, finaly we go checking up on tree if there is anothe violation in tree (This is not needed in insertation process only in deletation)
    /// running time: O(1)
    ///
    /// - parameter node: root node for which we choosing rotation, and then rotating his subtree and then recalculating heights.
    fileprivate func rotateAVLTree(node:BinarySearchTreeNode<T>, continueUp:Bool){
    
        var newParent : BinarySearchTreeNode<T>?
        if node.leftSubtreeHeight! > node.rightSubtreeHeight! && node.leftChild != nil && node.leftChild!.leftSubtreeHeight! >= node.leftChild!.rightSubtreeHeight!{
            newParent = rotateLeftLeft(parentNode: node)
        }else if node.leftSubtreeHeight! > node.rightSubtreeHeight! && node.leftChild != nil && node.leftChild!.leftSubtreeHeight! < node.leftChild!.rightSubtreeHeight!{
            newParent = rotateLeftRight(parentNode: node)
        }else if node.leftSubtreeHeight! < node.rightSubtreeHeight! && node.rightChild != nil && node.rightChild!.leftSubtreeHeight! > node.rightChild!.rightSubtreeHeight!{
            newParent = rotateRightLeft(parentNode: node)
        }else if node.leftSubtreeHeight! < node.rightSubtreeHeight! && node.rightChild != nil && node.rightChild!.leftSubtreeHeight! <= node.rightChild!.rightSubtreeHeight!{
            newParent = rotateRightRight(parentNode: node)
        }
        
        newParent!.leftChild?.leftSubtreeHeight = newParent!.leftChild?.leftChild == nil ? 0 : max(newParent!.leftChild!.leftChild!.leftSubtreeHeight!, newParent!.leftChild!.leftChild!.rightSubtreeHeight!) + 1
        newParent!.leftChild?.rightSubtreeHeight = newParent!.leftChild?.rightChild == nil ? 0 : max(newParent!.leftChild!.rightChild!.leftSubtreeHeight!, newParent!.leftChild!.rightChild!.rightSubtreeHeight!) + 1
        
        newParent!.rightChild?.leftSubtreeHeight = newParent!.rightChild?.leftChild == nil ? 0 : max(newParent!.rightChild!.leftChild!.leftSubtreeHeight!, newParent!.rightChild!.leftChild!.rightSubtreeHeight!) + 1
        newParent!.rightChild?.rightSubtreeHeight = newParent!.rightChild?.rightChild == nil ? 0 : max(newParent!.rightChild!.rightChild!.leftSubtreeHeight!, newParent!.rightChild!.rightChild!.rightSubtreeHeight!) + 1
        
        newParent!.leftSubtreeHeight = max(newParent!.leftChild!.leftSubtreeHeight!, newParent!.leftChild!.rightSubtreeHeight!) + 1
        newParent!.rightSubtreeHeight = max(newParent!.rightChild!.leftSubtreeHeight!, newParent!.rightChild!.rightSubtreeHeight!) + 1
        
        newParent!.leftChild?.numberOfChilds = (newParent!.leftChild?.leftChild?.numberOfChilds ?? 0) + (newParent!.leftChild?.rightChild?.numberOfChilds ?? 0) + 1
        newParent!.rightChild?.numberOfChilds = (newParent!.rightChild?.leftChild?.numberOfChilds ?? 0) + (newParent!.rightChild?.rightChild?.numberOfChilds ?? 0) + 1
        newParent!.numberOfChilds = (newParent!.leftChild?.numberOfChilds ?? 0) + (newParent!.rightChild?.numberOfChilds ?? 0) + 1
        
        if continueUp == true{
            goUpAndCheckRotations(node: node.parent, continueUp: continueUp)
        }else{
            var parentParent = newParent!.parent
            while parentParent != nil{
                parentParent!.numberOfChilds = (parentParent!.leftChild?.numberOfChilds ?? 0) + (parentParent!.rightChild?.numberOfChilds ?? 0) + 1
                parentParent = parentParent!.parent
            }
        }
    }
    
    // MARK:
    // MARK: Delete
    
    /// We call superclass method to delete node from tree, we get back node which we then need recalculate height, check his balance and then rotate hih subtree or (and) go up through tree and recheck balance
    /// running time: O(log(n))
    ///
    /// - parameter value: value that need to be deleted
    ///
    /// - returns: node that is first who need to be recalculate heights and check balance
    override func deleteWithParentReturned(value: T) -> BinarySearchTreeNode<T>? {
        let parent = super.deleteWithParentReturned(value: value)
        if parent == nil{return nil}
        if parent?.leftChild == nil{
            parent?.leftSubtreeHeight = 0
        }
        if parent?.rightChild == nil{
            parent?.rightSubtreeHeight = 0
        }
        
        if parent!.leftChild == nil && parent!.rightChild == nil{
            parent!.numberOfChilds = 1
        }else{
            parent!.numberOfChilds! -= 1
        }
        
        if parent!.isNodeBalanced(){
            goUpAndCheckRotations(node: parent!,continueUp: true)
        }else{
            rotateAVLTree(node: parent!,continueUp: true)
        }
        return parent
    }
    

    // MARK:
    // MARK: Rank
    
    /// New method specific for avl tree, we can get rank for each node. We can find the kth element (in order) of a binary tree
    /// - parameter index: order index o searching value
    ///
    /// - returns: value for searched index
    func objectOrderAtIndex(index:Int)->T?{
    
        if size <= index{
            return nil
        }
        
        return objectOrderHelper(index: index, node: rootNode!)
    }
    
    /// If k == left.size + 1, return data
    /// If k < left.size + 1, search for kth element in left subtree
    /// If k > left.size + 1, search for (k-left.size-1)th element in right sub-tree
    /// running time: O(log(n))
    ///
    /// - parameter index: order index o searching value
    /// - parameter node: current node
    ///
    /// - returns: value for searched index
    fileprivate func objectOrderHelper(index:Int,node:BinarySearchTreeNode<T>)->T?{
        
        if size <= index{
            return nil
        }
        
        if node.leftChild == nil && node.rightChild == nil{
            return node.value
        }else if node.leftChild == nil{
            if index == 0{
                return node.value
            }
            return objectOrderHelper(index: index - 1, node: node.rightChild!)
        }else if node.rightChild == nil{
            if index == node.leftChild!.numberOfChilds{
                 return node.value
            }
            return objectOrderHelper(index: index, node: node.leftChild!)
        }else if index == node.leftChild!.numberOfChilds{
            return node.value
        }else if index < node.leftChild!.numberOfChilds!{
            return objectOrderHelper(index: index, node: node.leftChild!)
        }else{
            return objectOrderHelper(index: index - (node.leftChild!.numberOfChilds! + 1), node: node.rightChild!)
        }
    }
    

}
