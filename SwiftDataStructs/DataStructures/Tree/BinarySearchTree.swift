//
//  BinarySearchTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 07/12/16.
//  Copyright © 2016 Tomislav Profico. All rights reserved.
//

import UIKit

class BinarySearchTreeNode<T: Comparable> {
    var leftChild : BinarySearchTreeNode<T>?{
        didSet{
            leftChild?.parent = self
        }
    }
    var rightChild : BinarySearchTreeNode<T>?{
        didSet{
            rightChild?.parent = self
        }
    }
    weak var parent : BinarySearchTreeNode<T>?
    
    var value : T
    
    var key : Int?
    
    var leftSubtreeHeight : Int?
    var rightSubtreeHeight : Int?
    var numberOfChilds : Int?
    
    init(value:T) {
        self.value = value
    }
    
    var containBootChild:Bool{
        get{
            return leftChild != nil && rightChild != nil
        }
    }
    
    var containOnlyLeftChild:Bool{
        get{
            return leftChild != nil && rightChild == nil
        }
    }
    
    var containOnlyRightChild:Bool{
        get{
            return leftChild == nil && rightChild != nil
        }
    }
    
    var containNoChild:Bool{
        get{
            return leftChild == nil && rightChild == nil
        }
    }
    
    var isRoot:Bool{
        get{
            return parent == nil
        }
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
    
    var oneChildNode:BinarySearchTreeNode<T>?{
        get{
            if containNoChild || containBootChild{return nil}
            if containOnlyLeftChild{return leftChild}
            return rightChild
        }
    }
}

class BinarySearchTree<T: Comparable> {
    
    var rootNode : BinarySearchTreeNode<T>?
    var size = 0
    
    /// Check if there is any element in search tree
    /// O(1)
    var isEmpty:Bool{
        get{
            return rootNode == nil
        }
    }
    
    // MARK:
    // MARK: Select and Search
    
    /// Get node for specified value of type T. 
    /// average running time: O(log(n))
    ///
    /// - parameter value:     searched value of type T.
    ///
    /// - returns: Node which value is equel to parametar value.
    /// If ther is no any node with value equel to value than return nil
    func select(value:T)->BinarySearchTreeNode<T>?{
    
        var newNode = rootNode
        while newNode != nil {
            if newNode!.value > value{
                newNode = newNode!.leftChild
            }else if newNode!.value < value{
                newNode = newNode!.rightChild
            }else{
                return newNode
            }
        }
        return nil
    }
    
    /// Get node which value is next bigger then value of parametar node
    /// average running time: O(log(n))
    ///
    /// - parameter node:     node for which we looking node with next bigger value
    ///
    /// - returns: Node which value is next bigger to parametar node.
    /// If parameter node value is biggest in tree return nil
    func successor(node: BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
    
        if node.rightChild == nil {return nil}
        var searchedNode = node.rightChild;
        while searchedNode?.leftChild != nil {
            searchedNode = searchedNode!.leftChild
        }
        return searchedNode
    }
    
    /// Get node which value is next smaller then value of parametar node
    /// average running time: O(log(n))
    ///
    /// - parameter node:     node for which we looking node with next smaller value
    ///
    /// - returns: Node which value is next smaller to parametar node.
    /// If parameter node value is smaller in tree return nil
    func predecessor(node: BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        
        if node.leftChild == nil {return nil}
        var searchedNode = node.leftChild;
        while searchedNode?.rightChild != nil {
            searchedNode = searchedNode!.rightChild
        }
        return searchedNode
    }
    
    /// Get min value of tree, and delete node with this value
    /// average running time: O(log(n))
    ///
    /// - returns: min value in tree
    /// If tree is empty return nil
    func extractMin()->T?{
    
        let value = minValue()
        if value != nil{_ = delete(value: value!)}
        return value
    }
    
    /// Get max value of tree, and delete node with this value
    /// average running time: O(log(n))
    ///
    /// - returns: max value in tree
    /// If tree is empty return nil
    func extractMax()->T?{
    
        let value = maxValue()
        if value != nil{_ = delete(value: value!)}
        return value
    }
    
    /// Get min value of tree, and do not delete this value
    /// average running time: O(log(n))
    ///
    /// - returns: min value in tree
    /// If tree is empty return nil
    func minValue()->T?{
        if rootNode == nil{return nil}
        var searchNode = rootNode
        
        while searchNode!.leftChild != nil {
            searchNode = searchNode!.leftChild
        }
        return searchNode!.value
    }
    
    /// Get max value of tree, and do not delete node with this value
    /// average running time: O(log(n))
    ///
    /// - returns: max value in tree
    /// If tree is empty return nil
    func maxValue()->T?{
        if rootNode == nil{return nil}
        var searchNode = rootNode
        
        while searchNode!.rightChild != nil {
            searchNode = searchNode!.rightChild
        }
        return searchNode!.value
    }
    
    /// Check if exist node with value in tree
    /// average running time: O(log(n))
    ///
    /// - parameter value:     value that is checked
    ///
    /// - returns: does node with parameter value exist in tree
    func containes(value:T)->Bool{
        
        var newNode = rootNode
        while newNode != nil {
            if newNode!.value > value{
                newNode = newNode!.leftChild
            }else if newNode!.value < value{
                newNode = newNode!.rightChild
            }else{
                return true
            }
        }
        return false
    }
    
    // MARK:
    // MARK: Insert and delete
    
    /// Create node with value equel value and inserting in tree
    /// average running time: O(log(n))
    ///
    /// - parameter value:     value that is inserted
    ///
    /// - returns: node that is creted in inserted in tree
    @discardableResult
    func insert(value : T)->BinarySearchTreeNode<T>{
    
        let node = BinarySearchTreeNode.init(value: value)
        size += 1
        
        // if tree is empty set new root node and return
        if rootNode == nil{
            rootNode = node
            return node;
        }
        
        var newNode = rootNode
        var previusNode : BinarySearchTreeNode<T>?
        while newNode != nil {
            previusNode = newNode
            if newNode!.value > value{
                newNode = newNode!.leftChild
            }else{
                newNode = newNode!.rightChild
            }
        }
        
        if previusNode!.value > value{
            previusNode!.leftChild = node
        }else{
            previusNode!.rightChild = node
        }
        
        return node
    }
    
    /// Delete node with value equel value
    /// average running time: O(log(n))
    ///
    /// - parameter value:     value that want to be deleted
    ///
    /// - returns: if there is no node that value is equel to value than return false else return true
    @discardableResult
    func delete(value:T)-> Bool{
        
        if rootNode == nil{
            return false
        }
    
        let parent = deleteWithParentReturned(value: value)
        if rootNode == nil{
            size = 0
            return true
        }
        if parent != nil{size -= 1}
        return parent != nil
    }
    
    /// Delete node with value equel value
    /// average running time: O(log(n))
    ///
    /// - parameter value:     value that want to be deleted
    ///
    /// - returns: return replaced node of deleted node, if there is no replacment for deleted nod return his parent, if no one node is deleted or deleted is root return nil
    internal func deleteWithParentReturned(value:T)->BinarySearchTreeNode<T>?{
    
        // select node which we want delete if this node not exist return false
        let node = select(value: value)
        if node == nil{return nil}
            // Check children of node that we want delete
            // if this node do not containes any children just delete it,
            // if this node contains only left or right child, delete this node, and make child of  this node to be child of parent of this node
            // if this node contains both child find node succesor, swap there value and delete succesor
        else if node!.containNoChild{
            removeNodeWithNoChildren(node: node!)
            return node!.parent
        }else if node!.containOnlyLeftChild || node!.containOnlyRightChild{
            return removeNodeWithOneChildren(node: node!)
        }else{
            let succ = predecessor(node: node!)
            let valueTmp = node!.value
            node!.value = succ!.value
            succ!.value = valueTmp
            if succ!.containNoChild{
                removeNodeWithNoChildren(node: succ!)
                return succ!.parent
            }else{
                return removeNodeWithOneChildren(node: succ!)
            }
        }
    }
    
    /// private methode, simple removing node with no children
    /// running time: O(1)
    ///
    /// - parameter node: node which we want to remove
    ///
    /// - return: parent of removed node
    internal func removeNodeWithNoChildren(node:BinarySearchTreeNode<T>){
    
        if node.isRoot{
            rootNode = nil
        }else if node.isLeftChild{
            node.parent!.leftChild = nil
        }else{
            node.parent!.rightChild = nil
        }
    }
    
    /// private methode, removing node with one child
    /// delete this node and make child of this node to be child of parent of this node
    /// running time: O(1)
    ///
    /// - parameter node: node which we want to remove
    ///
    /// - return: parent of removed node
    fileprivate func removeNodeWithOneChildren(node:BinarySearchTreeNode<T>) ->BinarySearchTreeNode<T>?{
        
        if node.isRoot{
            if node.leftChild != nil{
                rootNode = node.leftChild
            }
            else{
                rootNode = node.rightChild
            }
            return nil
        }else if node.isLeftChild{
            if node.leftChild != nil{
                node.parent!.leftChild = node.leftChild
                return node.leftChild
            }
            else{
                node.parent!.leftChild = node.rightChild
                return node.rightChild
            }
        }else{
            if node.leftChild != nil{
                node.parent!.rightChild = node.leftChild
                return node.leftChild
            }
            else{
                node.parent!.rightChild = node.rightChild
                return node.rightChild
            }
        }
    }
    
    // MARK:
    // MARK: Replace
    
    /// Just delete old value, and if is deleted then insert new one
    /// running time: O(log(n))
    ///
    /// - parameter oldValue: oldValue
    /// - parameter newValue: newValue
    func replace(oldValue:T,newValue:T){
        if delete(value: oldValue) == true{
            _ = insert(value: newValue)
        }
    }
    
    // MARK:
    // MARK: Rotation
    
    /// Internal methode, rotete left child of left child
    /// now child become new root of this subtree, parent become right child of his previus child, and grandchild stay left child of new subtree root
    /// running time: O(1)
    ///
    /// - parameter parentNode: node that is current root of this subtree
    ///
    /// - returns: new root of this subtree
    ///
    @discardableResult
    internal func rotateLeftLeft(parentNode:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let child = parentNode.leftChild
        
        replaceParent(parentNode: parentNode, child: child!)
        
        parentNode.leftChild = child!.rightChild
        child!.rightChild = parentNode
        
        return child!
    }
    
    /// Internal methode, rotete right child of right child
    /// now child become new root of this subtree, parent become left child of his previus child, and grandchild stay right child of new subtree root
    /// running time: O(1)
    ///
    /// - parameter parentNode: node that is current root of this subtree
    ///
    /// - returns: new root of this subtree
    ///
    @discardableResult
    internal func rotateRightRight(parentNode:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let child = parentNode.rightChild
        
        replaceParent(parentNode: parentNode, child: child!)
        
        parentNode.rightChild = child!.leftChild
        child!.leftChild = parentNode
        
        return child!
    }
    
    /// Internal methode, rotete right child of left child
    /// now grandChild become new root of this subtree, previus root of subtree become right child of new subtree root, and previus root child become left child of new subtree root
    /// running time: O(1)
    ///
    /// - parameter parentNode: node that is current root of this subtree
    ///
    /// - returns: new root of this subtree
    ///
    @discardableResult
    internal func rotateLeftRight(parentNode:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let child = parentNode.leftChild
        let grandChild = child!.rightChild
        
        replaceParent(parentNode: parentNode, child: grandChild!)
        
        parentNode.leftChild = grandChild!.rightChild
        child!.rightChild = grandChild!.leftChild
        grandChild!.leftChild = child
        grandChild!.rightChild = parentNode
        
        return grandChild!
    }
    
    /// Internal methode, rotete left child of right child
    /// now grandChild become new root of this subtree, previus root of subtree become left child of new subtree root, and previus root child become right child of new subtree root
    /// running time: O(1)
    ///
    /// - parameter parentNode: node that is current root of this subtree
    ///
    /// - returns: new root of this subtree
    ///
    @discardableResult
    internal func rotateRightLeft(parentNode:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>{
        
        let child = parentNode.rightChild
        let grandChild = child!.leftChild
        
        replaceParent(parentNode: parentNode, child: grandChild!)
        
        parentNode.rightChild = grandChild!.leftChild
        child!.leftChild = grandChild!.rightChild
        grandChild!.leftChild = parentNode
        grandChild!.rightChild = child
        
        return grandChild!
        
    }
    
    /// Private helper method, when rotating subtree this methode handle changing of swaping of parent between new and old subtree parent, also handle changing root of complete tree
    /// running time: O(1)
    ///
    /// - parameter parentNode: node that is previus root of this subtree
    /// - parameter child: node that is new root of this subtree
    ///
    fileprivate func replaceParent(parentNode:BinarySearchTreeNode<T>,child:BinarySearchTreeNode<T>){
    
        if parentNode === rootNode{
            rootNode = child
            rootNode?.parent = nil
        }else{
            if parentNode.isLeftChild{
                parentNode.parent!.leftChild = child
            }else{
                parentNode.parent!.rightChild = child
            }
        }
    }
    
    // MARK:
    // MARK: Helpers
    
    /// get node grandparent if exist
    /// running time: O(1)
    ///
    /// - parameter node: node for which we searching grandparent
    ///
    /// - returns: grandparent of parametar node if exist
    ///
    internal func grandparant(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        
        if node.parent == nil{return nil}
        return node.parent!.parent
    }
    
    /// get node uncle if exist
    /// running time: O(1)
    ///
    /// - parameter node: node for which we searching uncle
    ///
    /// - returns: uncle of parametar node if exist
    ///
    internal func uncle(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        
        if node.parent == nil{return nil}
        if node.parent!.parent == nil{return nil}
        if (node.parent!.isLeftChild){
            return node.parent!.parent!.rightChild
        }else{
            return node.parent!.parent!.leftChild
        }
    }
    
    /// get node sibling if exist
    /// running time: O(1)
    ///
    /// - parameter node: node for which we searching sibling
    ///
    /// - returns: sibling of parametar node if exist
    ///
    internal func sibling(node:BinarySearchTreeNode<T>)->BinarySearchTreeNode<T>?{
        if node.parent == nil{return nil}
        if (node.isRightChild){
            return node.parent!.leftChild
        }else{
            return node.parent!.rightChild
        }
    }
    
    // MARK:
    // MARK: Print tree
    
    /// helper methode which print tree
    ///
    func printTree(){
        if rootNode == nil{return}
        var nodes = [rootNode]
        
        while nodes.count > 0 {
            var s = ""
            for node in nodes{
                s.append("\(node!.value),\(node!.key ?? 0) ")
            }
            print(s)
            nodes = allChildrenOfChildrens(nodes: nodes as! [BinarySearchTreeNode<T>])
        }
        
    }
    /// helper method return all children of node
    /// running time: O(1)
    ///
    /// - parameter node: node for which we searching childrens
    ///
    /// - returns: array of node that are children of parametar node
    ///
    internal func allChildrenOfChildrens(nodes:[BinarySearchTreeNode<T>])->[BinarySearchTreeNode<T>]{
    
        var newNodes : [BinarySearchTreeNode<T>]? = []
        
        for node in nodes{
            if node.leftChild != nil{newNodes?.append(node.leftChild!)}
            if node.rightChild != nil{newNodes?.append(node.rightChild!)}
        }
        
        return newNodes!
    }
}

class BinarySearchTreeIterator<T :Comparable> : Iterator{
    
    let tree : BinarySearchTree<T>
    
    init(tree:BinarySearchTree<T>) {
        self.tree = tree
    }
    
    func hasNext() -> Bool {
        return !tree.isEmpty
    }
    
    func next() -> Any? {
        return tree.extractMin()
    }
    
    func hasPrevius() -> Bool {
        return !tree.isEmpty
    }
    
    func previus() -> Any? {
        return tree.extractMax()!
    }
    
}
