//
//  RedBlackTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 18/12/16.
//  Copyright © 2016 Tomislav Profico. All rights reserved.
//

import UIKit
import ObjectiveC

private var xoAssociationKey: UInt8 = 0

///Adding new property to node
///
internal extension BinarySearchTreeNode {
    var isDoubleBlackNode: Bool! {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? Bool
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

enum RBTreeColor : Int {
    case Red = 1
    case Black = 2
}

class RedBlackTree<T:Comparable>: BinarySearchTree<T> {
    
    // MARK:
    // MARK: Insert
    
    /// Call subclass to create and insert node and then check rotations and racoloring so tree stay balanced after insert
    /// running time: O(log(n))
    ///
    /// - parameter value:     value that is inserted
    ///
    /// - returns: node that is creted in inserted in tree
    @discardableResult
    override func insert(value: T)->BinarySearchTreeNode<T>{
        let l = super.insert(value: value)
        checkElement(node: l)
        return l
    }
    
    /// Check rotations and racoloring so tree stay balanced after insert
    /// If node is root color him as black, and return
    /// If node is red and his parent is red, there is violation in red black tree property and we need do some changes. If node uncle is black we search for rotation function, rotate subtree, get new subtree root and with this node recursively recheck tree, else if uncle is red we recolor subtree, get node grandparent and recursively recheck tree.
    /// running time: O(1)
    ///
    /// - parameter node: node of subtree that need to be recheck, and if needed rotate and recolor
    fileprivate func checkElement(node:BinarySearchTreeNode<T>){
        
        if (node.key == nil){
            node.key = RBTreeColor.Red.rawValue
        }else if node.key == RBTreeColor.Black.rawValue{
            return
        }
        
        if node.isRoot{
            node.key = RBTreeColor.Black.rawValue;
        }else if node.parent!.key != RBTreeColor.Black.rawValue{
            if uncleColor(node: node) == RBTreeColor.Black{
                let newRoot = rotateFunction(node: node)(node)
                checkElement(node: newRoot)
            }else{
                recolorNode(node: node)
                checkElement(node: grandparant(node: node)!)
            }
        }
    }
    
    /// Method that take node check his parent and granparent and check are they left or right child and choose one of four rotation function
    /// running time: O(1)
    ///
    /// - parameter node: node on which we choose rotaiton function
    ///
    /// - returns: rotation function based on parametar node and his parent and granparent
    fileprivate func rotateFunction(node:BinarySearchTreeNode<T>)->(BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        if node.parent?.leftChild === node && grandparant(node: node)?.leftChild === node.parent{
            return rotateLeftChildOfLeftChild
        }else if node.parent?.rightChild === node && grandparant(node: node)?.leftChild === node.parent{
            return rotateRightChildOfLeftChild
        }else if node.parent?.rightChild === node && grandparant(node: node)?.rightChild === node.parent{
            return rotateRightChildOfRightChild
        }else /*if node.parent?.leftChild === node && grandparant(node: node)?.rightChild === node.parent*/{
            return rotateLeftChildOfRightChild
        }
    }
    
    /// Call superclass rotateLeftLeft methode and recolor node so new parent is black and children red
    /// running time: O(1)
    ///
    /// - parameter node: grandchild node od subtree which we rotate
    ///
    /// - returns: new subtree root
    fileprivate func rotateLeftChildOfLeftChild(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let parent = node.parent
        let gParant = parent?.parent
        
        let newParent = rotateLeftLeft(parentNode: gParant!)
        
        newParent.leftChild?.key = RBTreeColor.Red.rawValue;
        newParent.key = RBTreeColor.Black.rawValue;
        newParent.rightChild?.key = RBTreeColor.Red.rawValue;
        
        return parent!;
    }
    
    /// Call superclass rotateRight methode and recolor node so new parent is black and children red
    /// running time: O(1)
    ///
    /// - parameter node: grandchild node od subtree which we rotate
    ///
    /// - returns: new subtree root
    fileprivate func rotateRightChildOfRightChild(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let parent = node.parent
        let gParant = parent?.parent
        
        let newParent = rotateRightRight(parentNode: gParant!)
        
        newParent.leftChild?.key = RBTreeColor.Red.rawValue;
        newParent.key = RBTreeColor.Black.rawValue;
        newParent.rightChild?.key = RBTreeColor.Red.rawValue;
        
        return parent!;
    }
    
    /// Call superclass rotateLeftRight methode and recolor node so new parent is black and children red
    /// running time: O(1)
    ///
    /// - parameter node: grandchild node od subtree which we rotate
    ///
    /// - returns: new subtree root
    fileprivate func rotateRightChildOfLeftChild(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let parent = node.parent
        let gParant = parent?.parent
        
        let newParent = rotateLeftRight(parentNode: gParant!)
        
        newParent.key = RBTreeColor.Black.rawValue
        newParent.leftChild?.key = RBTreeColor.Red.rawValue
        newParent.rightChild?.key = RBTreeColor.Red.rawValue
        
        return node
    }
    
    /// Call superclass rotateRightLeft methode and recolor node so new parent is black and children red
    /// running time: O(1)
    ///
    /// - parameter node: grandchild node od subtree which we rotate
    ///
    /// - returns: new subtree root
    fileprivate func rotateLeftChildOfRightChild(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let parent = node.parent
        let gParant = parent?.parent
        
        let newParent = rotateRightLeft(parentNode: gParant!)
        
        newParent.key = RBTreeColor.Black.rawValue
        newParent.leftChild?.key = RBTreeColor.Red.rawValue
        newParent.rightChild?.key = RBTreeColor.Red.rawValue
        
        return node
    }
    
    /// Recoler nodes, granparent become red, uncle and node become black
    /// running time: O(1)
    ///
    /// - parameter node: grandchild node od subtree which we recolor
    fileprivate func recolorNode(node:BinarySearchTreeNode<T>){
        
        let gParant = grandparant(node: node)
        if gParant?.parent != nil{
            gParant?.key = RBTreeColor.Red.rawValue;
        }
        
        let unc = uncle(node: node)
        unc?.key = RBTreeColor.Black.rawValue
        
        node.parent?.key = RBTreeColor.Black.rawValue
    }
    
    // MARK:
    // MARK: Delete
    
    /// Not calling sublass delete, use own logic to do that
    /// First select node we want to delete, if no such node return false
    /// If node is root and have no children just delete it and return
    /// Then swapped value with predecessor or succeor, if no children than no swaping just continue, else continue with predecessor / succesor node
    /// If new node is red and contains no children just delete it, else if new node is red, and it has one child which is black than just replace them with deletion of swaped node
    /// Else swaped node is double black node, and we use 6 cases to rotate and recolor tree, so it again become red black tree.
    /// running time: O(log(n))
    ///
    /// - parameter value:     value that is deleted
    ///
    /// - returns: is node deleted succesfully, or does note exist with value equel value
    @discardableResult
    override func delete(value: T) -> Bool {
        
        let node = select(value: value)
        if node == nil{return false}
        size -= 1
        if node === rootNode && node!.containNoChild{
            rootNode = nil
            return true
        }
        var swapedNode:BinarySearchTreeNode<T>?
        if node!.containOnlyLeftChild{
            swapedNode = swapPredecessor(node: node!)
        }else if node!.containOnlyRightChild{
            swapedNode = swapSuccessor(node: node!)
        }else if node!.containBootChild{
            swapedNode = swapPredecessor(node: node!)
        }else{
            swapedNode = node
        }
        
        if swapedNode!.key == RBTreeColor.Red.rawValue && swapedNode!.containNoChild{
            if (swapedNode === rootNode){rootNode = nil}
            else if swapedNode?.isRightChild == true{swapedNode?.parent!.rightChild = nil}
            else{swapedNode?.parent!.leftChild = nil}
            return true
        }
        
        if (swapedNode!.key == RBTreeColor.Red.rawValue && !swapedNode!.containNoChild) || (swapedNode!.key == RBTreeColor.Black.rawValue && swapedNode!.oneChildNode != nil && swapedNode!.oneChildNode!.key == RBTreeColor.Red.rawValue) {
            replaceWithChild(swapedNode: swapedNode!)
            return true
        }
        
        swapedNode?.isDoubleBlackNode = true
        
        var newDouble = swapedNode
        while newDouble != nil {
            newDouble = getDoubleBlackNodeDeletationFunction(node: newDouble!)(newDouble!)
        }
        
        if swapedNode!.isDoubleBlackNode == true{
            if swapedNode?.isRightChild == true{swapedNode!.parent!.rightChild = nil}
            else{swapedNode!.parent!.leftChild = nil}
        }
        
        return true;
    }
    
    /// Compering double black node relatives color to choose one of six methode which rotate and recolor subtree
    /// running time: O(1)
    ///
    /// - parameter node:     double black node
    ///
    /// - returns: one of six possible method that rotate or recolor subtree. It depands of double black node and there relatives node color which on method is use
    fileprivate func getDoubleBlackNodeDeletationFunction(node:BinarySearchTreeNode<T>)->(BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        if node === rootNode{return doubleBlackNodeIsRoot}
        
        let siblingC = siblingColor(node: node).rawValue
        let parentC = node.parent?.key!
        let siblingLeftChildrenColor = sibling(node: node)!.leftChild?.key! ?? RBTreeColor.Black.rawValue
        let siblingRightChildrenColor = sibling(node: node)!.rightChild?.key! ?? RBTreeColor.Black.rawValue
        let siblingInsideChildrenColor = sibling(node: node)!.isRightChild ? sibling(node: node)!.leftChild?.key! ?? RBTreeColor.Black.rawValue : sibling(node: node)!.rightChild?.key! ?? RBTreeColor.Black.rawValue
        let siblingOutsideChildrenColor = sibling(node: node)!.isRightChild ? sibling(node: node)!.rightChild?.key! ?? RBTreeColor.Black.rawValue : sibling(node: node)!.leftChild?.key! ?? RBTreeColor.Black.rawValue
        
        if parentC == RBTreeColor.Black.rawValue && siblingC == RBTreeColor.Red.rawValue{
            return doubleBlackNodeSiblingRed
        }
        else if parentC == RBTreeColor.Black.rawValue && siblingC == RBTreeColor.Black.rawValue && siblingLeftChildrenColor == RBTreeColor.Black.rawValue && siblingRightChildrenColor == RBTreeColor.Black.rawValue{
            return doubleBlackNodeSiblingBlackParentBlackAllSiblingChildrenBlack
        }
        else if parentC == RBTreeColor.Red.rawValue && siblingC == RBTreeColor.Black.rawValue && siblingLeftChildrenColor == RBTreeColor.Black.rawValue && siblingRightChildrenColor == RBTreeColor.Black.rawValue{
            return doubleBlackNodeSiblingBlackParentRedAllSiblingChildrenBlack
        }
        else if  siblingC == RBTreeColor.Black.rawValue && siblingInsideChildrenColor == RBTreeColor.Red.rawValue && siblingOutsideChildrenColor == RBTreeColor.Black.rawValue{
            return doubleBlackNodeSiblingBlackParentBlackInsideSiblingChildRedOutsideBlack
        }
        else if  siblingC == RBTreeColor.Black.rawValue &&  siblingOutsideChildrenColor == RBTreeColor.Red.rawValue{
            return doubleBlackNodeSiblingBlackOutsideSiblingChildRed
        }
        
        return doubleBlackNodeIsRoot
    }
    
    /// If double black node is root just recolor it to be black and finish
    /// running time: O(1)
    ///
    /// - parameter node:     double black node
    ///
    /// - returns: nil, because this state is terminal state and no more rotation and recoloring is needed, because red black tree is restored.
    fileprivate func doubleBlackNodeIsRoot(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        node.key = RBTreeColor.Black.rawValue
        return nil
    }
    
    /// If node parent is black, node sibling is red, then rotateRightRight or rotateLeftLeft around sibling node. Sibling node now become subtree root, and change color to black, previus subtree root now change color to red. This is not terminal case so procedure have to continue, double black node stay same.
    /// running time: O(1)
    ///
    /// - parameter node:     double black node
    ///
    /// - returns: same as parametar node, because this state in not terminal state, and double black node stay same.
    fileprivate func doubleBlackNodeSiblingRed(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
    
        let nodeParent = node.parent
        
        let nextParent : BinarySearchTreeNode<T>
        if node.isLeftChild{
            nextParent = rotateRightRight(parentNode: nodeParent!)
        }else{
            nextParent = rotateLeftLeft(parentNode: nodeParent!)
        }
        
        nextParent.key = RBTreeColor.Black.rawValue
        nodeParent!.key = RBTreeColor.Red.rawValue
        
        return node
    }
    
    /// If node parent is black, node sibling is black, and all children of sibling is black, then change color of sibling to red, double black node is now black, and his parent is now double black node, so problem is translate up.This is not terminal case so procedure have to continue.
    /// running time: O(1)
    ///
    /// - parameter node:     double black node
    ///
    /// - returns: parametar node parent, who is now double black tree, so problem is translate up in tree. This is not terminal state.
    fileprivate func doubleBlackNodeSiblingBlackParentBlackAllSiblingChildrenBlack(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        
        let nodeSibling = sibling(node: node)
        let nodeParent = node.parent
        
        nodeSibling?.key = RBTreeColor.Red.rawValue
        node.key = RBTreeColor.Black.rawValue
        
        return nodeParent
        
    }
    
    /// If node parent is red, node sibling is black, and all children of sibling is black, then change color of sibling to red, and change color of parent to black, double black node is now black, and there is no more double black node, so red black tree is valid again and this is terminal state.
    /// running time: O(1)
    ///
    /// - parameter node:     double black node
    ///
    /// - returns: nil, this is terminal state.
    fileprivate func doubleBlackNodeSiblingBlackParentRedAllSiblingChildrenBlack(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        
        let nodeSibling = sibling(node: node)
        let nodeParent = node.parent
        
        node.key = RBTreeColor.Black.rawValue
        nodeParent!.key = RBTreeColor.Black.rawValue
        nodeSibling!.key = RBTreeColor.Red.rawValue
        
        return nil
        
    }
    
    /// If node parent is black or red, node sibling is black, inside sibling child is red and outside is black, then rotate such that inside sibling child become new sibling of double black node, and change color to black, his outside child is now previus sibling who change color to red. Double black node stay same, so this is not terminal state
    /// running time: O(1)
    ///
    /// - parameter node:  double black node
    ///
    /// - returns: same as parametar node, because this state in not terminal state, and double black node stay same.
    fileprivate func doubleBlackNodeSiblingBlackParentBlackInsideSiblingChildRedOutsideBlack(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        
        let nodeSibling = sibling(node: node)
        let nodeParent = node.parent
        let leftChild = nodeSibling!.leftChild
        let rightChild = nodeSibling!.rightChild
        
        if nodeSibling!.isRightChild{
        
            nodeSibling!.leftChild = leftChild?.rightChild
            leftChild!.rightChild = nodeSibling
            nodeParent!.rightChild = leftChild
            
            leftChild!.key = RBTreeColor.Black.rawValue
            nodeSibling!.key = RBTreeColor.Red.rawValue
        }else{
        
            nodeSibling!.rightChild = rightChild?.leftChild
            rightChild!.leftChild = nodeSibling
            nodeParent!.leftChild = rightChild
            
            rightChild!.key = RBTreeColor.Black.rawValue
            nodeSibling!.key = RBTreeColor.Red.rawValue
        }
        
        return node
    }
    
    
    /// If node sibling is black, and outside sibling child is red, then rotate around sibling using rotateRightRight or rotateLeftLeft, sibling is new root node of subtree and it color is same as previus subtree root, previus root and double black node become black, as same as previus outside sibling child. Double black node not exist any more so this is terminal state.
    /// running time: O(1)
    ///
    /// - parameter node:  double black node
    ///
    /// - returns: nil, this is terminal state.
    fileprivate func doubleBlackNodeSiblingBlackOutsideSiblingChildRed(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        
        let nodeSibling = sibling(node: node)
        let nodeParent = node.parent
        let leftChild = nodeSibling!.leftChild
        let rightChild = nodeSibling!.rightChild
        let isRightChild = nodeSibling!.isRightChild
        
        if node.isLeftChild{
            _ = rotateRightRight(parentNode: nodeParent!)
        }else{
            _ = rotateLeftLeft(parentNode: nodeParent!)
        }
        
        if isRightChild == true{
            rightChild?.key = RBTreeColor.Black.rawValue
        }else{
            leftChild?.key = RBTreeColor.Black.rawValue
        }
        nodeSibling!.key = nodeParent!.key
        nodeParent!.key = RBTreeColor.Black.rawValue
        node.key = RBTreeColor.Black.rawValue
        
        return nil
    }
    
    /// Input is node that need to be deleted and now his child become child of his parent, and have black color now.
    /// running time: O(1)
    ///
    /// - parameter node:  double black node who has one child. This node need to be deleted
    fileprivate func replaceWithChild(swapedNode:BinarySearchTreeNode<T>?){
        
        if swapedNode!.oneChildNode == nil{return}
        
        if swapedNode!.key == RBTreeColor.Black.rawValue && swapedNode!.oneChildNode!.key == RBTreeColor.Red.rawValue{
            swapedNode!.oneChildNode!.key = RBTreeColor.Black.rawValue
        }
        
        if swapedNode!.isLeftChild{
            swapedNode!.parent!.leftChild = swapedNode!.oneChildNode
        }else if swapedNode!.isRightChild{
            swapedNode!.parent!.rightChild = swapedNode!.oneChildNode
        }
    }
    
    // MARK:
    // MARK: Helper
    
    /// Find succesor of node, and now node value become value of succesor
    /// running time: O(log(n))
    ///
    /// - parameter node:  node for which we search succesor, and changing value to succesor value
    ///
    /// - return: Succesor node
    fileprivate func swapSuccessor(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        let s =  successor(node: node)
        node.value = s!.value
        return s!
    }
    
    /// Find predecessor of node, and now node value become value of predecessor
    /// running time: O(log(n))
    ///
    /// - parameter node:  node for which we search predecessor, and changing value to predecessor value
    ///
    /// - return: Predecessor node
    fileprivate func swapPredecessor(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        let s =  predecessor(node: node)
        node.value = s!.value
        return s!
    }
    
    /// Get color of uncle node, if not exist return black (nil node)
    /// running time: O(1)
    ///
    /// - parameter node:  node for which we searching uncle color
    ///
    /// - return: Uncle color
    fileprivate func uncleColor(node:BinarySearchTreeNode<T>)->RBTreeColor{
    
        let unc = uncle(node: node)
        if unc == nil {return RBTreeColor.Black}
        else {return RBTreeColor.init(rawValue: unc!.key!)!}
    }
    
    /// Get color of sibling node, if not exist return black (nil node)
    /// running time: O(1)
    ///
    /// - parameter node:  node for which we searching sibling color
    ///
    /// - return: Sibling color
    fileprivate func siblingColor(node:BinarySearchTreeNode<T>)->RBTreeColor{
    
        let sibl = sibling(node: node)
        if sibl == nil{return RBTreeColor.Black}
        else{return RBTreeColor.init(rawValue: sibl!.key!)!}
    }
}
