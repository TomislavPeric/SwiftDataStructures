//
//  TernaryTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 09/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

extension String {
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
}

class TernaryNode<K>{

    // every node has key (single charachter)
    var key:Character
    
    // if node is final node of string key, then it hold stored value
    var value : K?
    
    weak var parent:TernaryNode<K>?
    
    var leftChild:TernaryNode<K>?{
        didSet{
            leftChild?.parent = self
        }
    }
    
    var rightChild:TernaryNode<K>?{
        didSet{
            rightChild?.parent = self
        }
    }
    
    var centerChild:TernaryNode<K>?{
        didSet{
            centerChild?.parent = self
        }
    }
    
    init(key:Character) {
        self.key = key
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
    
    var isCentarChild:Bool{
        get{
            return parent != nil && parent!.centerChild === self
        }
    }
    
    // remove self and all his children
    func removeSelf(){
        if isLeftChild{
            self.parent?.leftChild = nil
        }else if isRightChild{
            self.parent?.rightChild = nil
        }else if isCentarChild{
            self.parent?.centerChild = nil
        }
    }
    
    // remove self and replace with left child
    func replaceSelfWithLeftNode(){
        if self.isCentarChild{
            self.parent?.centerChild = self.leftChild
        }else if self.isLeftChild{
            self.parent?.leftChild = self.leftChild
        }else if self.isRightChild{
            self.parent?.rightChild = self.leftChild
        }
    }
    
    // remove self and replace with left child
    func replaceSelfWithRightNode(){
        if self.isCentarChild{
            self.parent?.centerChild = self.rightChild
        }else if self.isLeftChild{
            self.parent?.leftChild = self.rightChild
        }else if self.isRightChild{
            self.parent?.rightChild = self.rightChild
        }
    }
    
    func finalRightNode()->TernaryNode<K>?{
        
        if self.rightChild == nil{
            return nil
        }
    
        var node = self.rightChild!
        
        while node.rightChild != nil {
            node = node.rightChild!
        }
    
        return node
    }

}

// Can be use similar to hash map, just key must be string
class TernaryTree<K> {
    
    // root of tree in start it is empty
    fileprivate var root:TernaryNode<K>?
    
    // subscript that can insert value, and search for the value
    subscript(key: String) -> K? {
        get {
            return search(key: key)
        }
        set(newValue) {
            if newValue != nil{
                insert(key: key, value: newValue)
            }else{
                delete(key: key)
            }
        }
    }
    
    // MARK:
    // MARK: Insert
    
    
    /// insert key-value in tree, key must be string and value can be anything. First checking if key is empty, then we check if root is empty if yes we insert first charachter as new key of root node and continue inserting other key carachter in tree
    /// Average runtime: O(log n)
    ///
    /// - parameter key: string key added to tree
    /// - parameter value: value added for given key
    func insert(key:String, value:K?){
        
        assert(!key.isEmpty,"Inserted key can not be empty")
    
        if root == nil{
            root = TernaryNode<K>.init(key: key.lowercased().characters.first!)
            if key.characters.count == 1{
                root?.value = value
                return
            }else{
                insertHelper(key: key, node: root!, position: 0, value: value)
            }
        }else{
            insertHelper(key: key, node: root!, position: 0, value: value)
        }
    
    }
    
    /// Helper methd that recursively insert charachter by charachter, we get value of next carachter to be inserted then cheking if center child of current node is nil if yes insert new node with current caracter to tree as center child of current node, else we checking if key of central child of current node if equel to current charachter then icrement position of current key node and recursively call this method again inserting next charachter. Else we checking if current charachter is less then curren node key charachter if yes go left recursivley else go right recursivly until we insert all charachter, at final charachter we insert value for node nd finish process.
    ///
    /// - parameter key: string key added to tree
    /// - parameter value: value added for given key
    /// - parameter node: current node (final node that is check)
    /// - parameter position: posiiton of current charachter that we want check (insert if not exist in proper position)
    fileprivate func insertHelper(key:String,node:TernaryNode<K>,position:Int,value:K?){
        
        if position >= key.characters.count{
            node.parent!.value = value
            return
        }
        
        let currentCharachter = key.lowercased()[position]
        let index = key.index(key.startIndex, offsetBy: position + 1)
        let string = key.substring(from: index)
    
        if node.key == currentCharachter{
            if node.centerChild == nil{
                insertToEnd(string: string, node: node, value: value)
            }else{
                insertHelper(key: key, node: node.centerChild!, position: position + 1, value: value)
            }
        }else if currentCharachter.asciiValue! < node.key.asciiValue!{
            if node.leftChild == nil{
                node.leftChild = TernaryNode<K>.init(key: currentCharachter)
                insertToEnd(string: string, node: node.leftChild!, value: value)
            }else{
                insertHelper(key: key, node: node.leftChild!, position: position, value: value)
            }
        }else{
            if node.rightChild == nil{
                node.rightChild = TernaryNode<K>.init(key: currentCharachter)
                insertToEnd(string: string, node: node.rightChild!, value: value)
            }else{
                insertHelper(key: key, node: node.rightChild!, position: position, value: value)
            }
        }
    }
    
    /// insert given string to the end , for every charachter create new node that is center child of vurrent node
    ///
    /// - parameter string: string key to inserte to the end
    /// - parameter node: curent node
    /// - parameter value: value to insert at final node
    fileprivate func insertToEnd(string:String,node:TernaryNode<K>,value:K?){
        
        guard node.centerChild == nil else {
            return
        }
        
        guard !string.isEmpty else {
            node.value = value
            return
        }
        
        let first = string.characters.first!
        let n = TernaryNode<K>.init(key: first)
        node.centerChild = n
        
        let newString = String(string.characters.dropFirst())
        
        guard newString.characters.count != 0 else {
            n.value = value
            return
        }
        
        insertToEnd(string: newString, node: n, value: value)
        
    }
    
    // MARK:
    // MARK: Search
    
    /// Search for key in tree if exist return value for that key else return nil
    /// Average runtime: O(log n)
    ///
    /// - parameter key: string key which value is searched
    ///
    /// - return: value which is stored by given key
    func search(key:String)->K?{
    
        guard !key.isEmpty else {
            return nil
        }
        
        guard root != nil else {
            return nil
        }
        
        return searchHelper(key: key, node: root!, position: 0)?.value
    }
    
    /// Helper method that recursivly go charachter by charachter of given key, and searching if exist, if not exist return nil, else return node with final key charachter that store key value.
    ///
    /// - parameter key: string key which value is searched
    /// - parameter node: current node
    /// - parameter position: current position of charachter in key
    ///
    /// - return: node with final key charachter that store key value.
    fileprivate func searchHelper(key:String,node:TernaryNode<K>,position:Int)->TernaryNode<K>?{
        
        if position >= key.characters.count{
            return nil
        }
        
        let currentCharachter = key.lowercased()[position]
        
        if currentCharachter == node.key{
            if key.characters.count == position + 1{
                return node
            }else{
                if node.centerChild == nil{
                    return nil
                }else{
                    return searchHelper(key: key, node: node.centerChild!, position: position + 1)
                }
            }
        }else if currentCharachter.asciiValue! < node.centerChild!.key.asciiValue!{
            if node.leftChild == nil{
                return nil
            }else{
                return searchHelper(key: key, node: node.leftChild!, position: position)
            }
        }else{
            if node.rightChild == nil{
                return nil
            }else{
                return searchHelper(key: key, node: node.rightChild!, position: position)
            }
        }
    }
    
    // MARK:
    // MARK: Delete
    
    /// Delete value with given key from tree
    /// Average runtime: O(log n)
    ///
    /// - parameter key: string key which value is deleted
    func delete(key:String){
        
        guard !key.isEmpty else {
            return
        }
        
        guard root != nil else {
            return
        }
    
        let node = searchHelper(key: key, node: root!, position: 0)
        
        guard node != nil else {
            return
        }
        
        node!.value = nil
        deleteUp(node: node!)
    
    }
    
    /// We go up to tree and checking if we can delete current node, base on if it store vlue, and does he have child, and are they storing value.
    ///
    /// - parameter node: current node
    fileprivate func deleteUp(node:TernaryNode<K>){
    
        if node.value != nil{
            return
        }
        
        if node.centerChild != nil{
            return
        }
        
        if node.leftChild != nil && node.rightChild != nil{
            
            let fRightNode = node.leftChild!.finalRightNode()
            let rNode = node.rightChild!
            let lNode = node.leftChild!
            
            if fRightNode == nil{
                node.replaceSelfWithLeftNode()
                lNode.rightChild = rNode
                return
            }else if fRightNode === lNode.rightChild{
                lNode.rightChild = fRightNode!.leftChild
            }else{
                fRightNode!.removeSelf()
            }
            
            fRightNode!.leftChild = lNode
            node.leftChild = fRightNode
            node.replaceSelfWithLeftNode()
            fRightNode!.rightChild = rNode
            
            
        }else if node.leftChild == nil && node.rightChild == nil{
            node.removeSelf()
            if node.parent != nil{
                deleteUp(node: node.parent!)
            }
        }else if node.leftChild == nil{
            node.replaceSelfWithRightNode()
        }else{
            node.replaceSelfWithLeftNode()
        }
    }
}
