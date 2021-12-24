//
//  BTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 21/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class BTreeNode<K : Comparable, V> {
    
    // each node have array of key and assoiated values
    var keys: [K]
    var values : [V]
    
    // Each node with n keys have n + 1 children
    var childrens : [BTreeNode?]?
    
    // We need track node parent and index in parent children which point to this node
    weak var parent : BTreeNode?
    var numberInParent : Int?
    
    init() {
        keys = []
        values = []
    }
    
    /// Insert key and value in node at end of array
    ///
    /// - paramatar key: key append
    /// - paramatar value: value append
    func append(key:K, value:V){
        keys.append(key)
        values.append(value)
    }
    
    /// Insert key and value in node at some index
    ///
    /// - paramatar key: key inserted
    /// - paramatar value: value inserted
    /// - index in which key and value are inserted
    func insert(key:K, value:V,index:Int){
        keys.insert(key, at: index)
        values.insert(value, at: index)
    }
    
    /// append node at children array in end of array, if array is nil create it.
    ///
    /// - paramatar child: child appended
    func appendChild(child:BTreeNode){
    
        if childrens == nil{
            childrens = []
        }
        child.parent = self
        child.numberInParent = childrens!.count
        childrens!.append(child)
    }
    
    func removeChildAtIndex(index:Int){
        
        _ = childrens?.remove(at: index)
        for i in index..<childrens!.count{
            childrens![i]!.numberInParent = i
            childrens![i]!.parent = self
        }
        
        
    }
    
    func insertChildAtIndex(index:Int,child:BTreeNode){
        if childrens == nil{
            childrens = []
        }
        
        childrens?.insert(child, at: index)
        for i in index..<childrens!.count{
            childrens![i]!.numberInParent = i
            childrens![i]!.parent = self
        }
    }
    
    /// midle key index
    func middleKeyIndex()->Int{
        return keys.count / 2
    }
    
    /// split node in two node, left and right, both contains n/2 keys, value and childrens
    ///
    /// - return: left and right node of node that is splited
    func split()->[BTreeNode<K,V>]{
    
        let left = BTreeNode<K,V>.init()
        for i in 0..<middleKeyIndex(){
            left.append(key: keys[i], value: values[i])
            if i < (childrens?.count ?? 0){ left.appendChild(child: childrens![i]!)}
        }
        
        if middleKeyIndex() < (childrens?.count ?? 0){ left.appendChild(child: childrens![middleKeyIndex()]!)}
        
        let right = BTreeNode<K,V>.init()
        for j in middleKeyIndex() + 1..<keys.count{
            right.append(key: keys[j], value: values[j])
            if j < (childrens?.count ?? 0) { right.appendChild(child: childrens![j]!) }
        }
        
        if childrens != nil{ right.appendChild(child: childrens![childrens!.count - 1]!)}
        
        return [left,right]
    }
    
    /// insert splited nodes to parent
    ///
    /// - parameters key: middle key of splited node
    /// - parameters value: middle value of splited node
    /// - parameters leftChild: left split node
    /// - parameters rightChild: right split node
    /// - parameters index: index of splited node
    func insertNodeFromChild(key:K, value:V, leftChild:BTreeNode<K,V>, rightChild:BTreeNode<K,V>, index:Int){
    
        childrens?[index] = leftChild
        leftChild.parent = self
        leftChild.numberInParent = index
        
        rightChild.parent = self
        rightChild.numberInParent = index + 1
        
        if index <= keys.count{
            insert(key: key, value: value, index: index)
            childrens?.insert(rightChild, at: index + 1)
        }else{
            append(key: key, value: value)
            childrens?.append(rightChild)
        }
    }
    
    /// remove key and value from index
    func removeKV(index:Int){
    
        keys.remove(at: index)
        values.remove(at: index)
    }
    
    /// replace key and value from index
    func replace(index:Int,key:K,value:V){
    
        keys[index] = key
        values[index] = value
    }
    
    /// marge two node, add all keys, value, and children from parameter nod to end of current node
    ///
    /// paamater: node merge with current node
    func marge(node:BTreeNode<K,V>){
    
        if node.keys.count != 0{
            for key in node.keys{
                keys.append(key)
            }
            
            for value in node.values{
                values.append(value)
            }
        }
        
        guard node.childrens != nil else {
            return
        }
        
        for child in node.childrens!{
            appendChild(child: child!)
        }
    
    }
}

class BTree<K : Comparable, V> {

    fileprivate var root : BTreeNode<K, V>?
    var size : Int
    fileprivate var order : Int
    
    init(order:Int) {
        self.order = order
        self.size = 0
    }
    
    // MARK:
    // MARK: Search
    
    ///Linear search for key k on the keys of the node.
    ///If k == l then we have found the key.
    ///If k < l:
    ///If the node we are on is not a leaf, then we go to the left child of l, and perform this steps again
    ///If we are on a leaf, then k is not in the tree.
    ///If we have reached the end of the array:
    ///If we are on a non-leaf node, then we go to the last child of the node, and perform the steps 3 - 5 again.
    ///If we are on a leaf, then k is not in the tree.
    func search(key:K)->V?{
        return searchHelper(key:key, currentNode:root)
    }
    

    fileprivate func searchHelper(key:K,currentNode:BTreeNode<K,V>?)->V?{
    
        guard currentNode != nil else {
            return nil
        }

        var index = 0
        for i in 0..<currentNode!.keys.count{
            index = i
            if currentNode!.keys[index] >= key{
                break
            }
        }
        
        if currentNode!.keys[index] == key{
            return currentNode!.values[index]
        }else if currentNode!.keys[index] > key{
            return searchHelper(key: key, currentNode: currentNode!.childrens?[index])
        }else{
            return searchHelper(key: key, currentNode: currentNode!.childrens?[index + 1])
        }
    
    }
    
    // MARK:
    // MARK: Insert
    
    ///Keys can only be inserted to leaf nodes. Search for key, if exist change it value, else after the search the key k we are on key  bigger than k than insert new key before k else insert after k. After insert we need to check if need to split node
    ///
    /// parameter key - key inserted
    /// parameter value - value inserted
    func set(key:K,value:V){
    
        guard root != nil && root!.keys.count > 0 else {
            root = BTreeNode<K,V>.init()
            root?.append(key: key, value: value)
            return
        }
        
        setHelper(key: key, value: value, currentNode: root)
    }
    
    fileprivate func setHelper(key:K, value:V, currentNode:BTreeNode<K,V>?){
        
        guard currentNode != nil else {
            return
        }
        
        var index = 0
        for i in 0..<currentNode!.keys.count{
            index = i
            if currentNode!.keys[index] >= key{
                break
            }
        }
        
        if currentNode!.keys[index] == key{
            
            currentNode!.values[index] = value
            return
            
        }else if currentNode!.keys[index] > key{
            
            if currentNode!.childrens == nil{
                
                currentNode!.insert(key: key, value: value, index: index)
                checkSplit(node: currentNode!)
                
            }else{
                setHelper(key: key, value: value, currentNode: currentNode!.childrens?[index])
            }
            
        }else{
            
            if currentNode!.childrens == nil{
                
                currentNode!.append(key: key, value: value)
                checkSplit(node: currentNode!)
                
            }else{
                setHelper(key: key, value: value, currentNode: currentNode!.childrens?[index + 1])
            }
        }
    }
    
    // MARK:
    // MARK: Split
    
    /// check if we need split node after insertation, this is true if number of keys in node is equel to order of tree
    ///
    /// - parameter node: node to check
    fileprivate func checkSplit(node:BTreeNode<K,V>){
        
        if node.keys.count == order{
            split(node: node)
        }
    }
    
    /// Move  middle key of parameter node to his parent. If node is root create new root and insert middle key and value to it.
    /// Split node into two with keys and values before and after middle key. Add this node to parent. After splitting a node  parent node can also contain too many keys, so need to be splited.
    ///
    /// - parameter node: node to check
    fileprivate func split(node:BTreeNode<K,V>){
        
        let data = node.split()
        let left = data.first!
        let right = data.last!
        
        if node === root{
        
            root = BTreeNode<K,V>.init()
            root!.append(key: node.keys[node.middleKeyIndex()], value: node.values[node.middleKeyIndex()])
            root!.appendChild(child: left)
            root!.appendChild(child: right)
            
        }else{
    
            let parent = node.parent!
            parent.insertNodeFromChild(key: node.keys[node.middleKeyIndex()], value: node.values[node.middleKeyIndex()],leftChild: left, rightChild: right, index: node.numberInParent ?? -1)
            checkSplit(node: parent)
        
        }
        
    }
    
    // MARK:
    // MARK: Remove
    
    ///If we are on a leaf node we can remove key. else we ofind predecesor replace two and remove predesesor, after that we need to check if nodes have to be moved.
    ///
    /// - parameters key: key need to be removed
    func remove(key:K){
        
        guard root != nil else {
            return
        }
        
        removeHelper(key: key, currentNode: root)
    }
    
    /// use for search of key when found call remove node method
    /// 
    /// - parametar key: key to be removed
    /// - parameter currentNode: current node.
    fileprivate func removeHelper(key:K,currentNode:BTreeNode<K,V>?){
        
        guard currentNode != nil else {
            return
        }
        
        var index = 0
        for i in 0..<currentNode!.keys.count{
            index = i
            if currentNode!.keys[index] >= key{
                break
            }
        }
        
        if currentNode!.keys[index] == key{
            removeNode(node:currentNode,index: index)
            return
        }else if currentNode!.keys[index] > key{
            removeHelper(key: key, currentNode: currentNode!.childrens?[index])
        }else{
            removeHelper(key: key, currentNode: currentNode!.childrens?[index + 1])
        }
        
    }

    fileprivate func removeNode(node:BTreeNode<K,V>?,index:Int){
    
        guard node != nil else {
            return
        }
        if node!.childrens == nil{
            node!.removeKV(index: index)
            checkMove(nodeToCheck: node!)
        }else{
            let predecesor = predesesor(node: node!.childrens![index]!)
            node!.replace(index: index, key: predecesor.keys[predecesor.keys.count - 1], value: predecesor.values[predecesor.values.count - 1])
            predecesor.removeKV(index: predecesor.keys.count - 1)
            checkMove(nodeToCheck: predecesor)
        }
        
    }
    
    /// check if node have to small number of keys if yes need to be rearange
    ///
    /// - parameters nodeToCheck: node to check
    fileprivate func checkMove(nodeToCheck:BTreeNode<K,V>){
        
        guard nodeToCheck !== root else {
            return
        }
    
        if nodeToCheck.keys.count < order / 2{
            moveNode(node: nodeToCheck)
        }
    }
    
    /// check if we can borrow key from sibling if yes do that, else merge with parent
    ///
    /// - parameters moveNode: node to rearange
    fileprivate func moveNode(node:BTreeNode<K,V>){
        
        if node.parent == nil{
            return
        }
        
        let num = node.numberInParent
        
        if num != 0 && node.parent!.childrens![num! - 1]!.keys.count > order / 2{
            
            exchangeKeys(node: node, sibling: node.parent!.childrens![num! - 1]!, isLeft: true)
            return
        }
        if num! + 1 < node.parent!.childrens!.count && node.parent!.childrens![num! + 1]!.keys.count > order / 2{
        
            exchangeKeys(node: node, sibling: node.parent!.childrens![num! + 1]!, isLeft: false)
            return
        }
        
        marge(node: node)
    }
    
    fileprivate func marge(node:BTreeNode<K,V>){
    
        guard node.parent != nil else {
            return
        }
        
        let num = node.numberInParent
        
        if num != 0{
            let sibling = node.parent!.childrens![num! - 1]!
            sibling.append(key: node.parent!.keys[num! - 1], value: node.parent!.values[num! - 1])
            node.parent!.removeKV(index: num! - 1)
            sibling.marge(node: node)
            if node.parent!.keys.count == 0{
                if node.parent! === root{
                    root = sibling
                }else{
                    node.parent!.removeChildAtIndex(index: num!)
                }
            }else{
                node.parent!.removeChildAtIndex(index: num!)
            }
        }else{
            let sibling = node.parent!.childrens![num! + 1]!
            node.append(key: node.parent!.keys[num!], value: node.parent!.values[num!])
            node.parent!.removeKV(index: num!)
            node.marge(node: sibling)
            if node.parent!.keys.count == 0{
                if node.parent! === root{
                    root = node
                }else{
                    node.parent!.removeChildAtIndex(index: num! + 1)
                }
            }else{
                node.parent!.removeChildAtIndex(index: num! + 1)
            }
        }
        if node !== root{
            checkMove(nodeToCheck: node.parent!)
        }
    }
    
    fileprivate func exchangeKeys(node:BTreeNode<K,V>,sibling:BTreeNode<K,V>,isLeft:Bool){
    
        let parent = node.parent!
        let parentNum = node.numberInParent!
        
        if isLeft{
        
            node.insert(key: parent.keys[parentNum - 1], value: parent.values[parentNum - 1], index: 0)
            parent.replace(index: parentNum - 1,key: sibling.keys[sibling.keys.count - 1], value: sibling.values[sibling.values.count - 1])
            sibling.removeKV(index: sibling.keys.count - 1)
            
            if node.childrens != nil{
                let child = sibling.childrens!.last!
                _ = sibling.childrens!.removeLast()
                node.insertChildAtIndex(index: 0, child: child!)
            }
        
        }else{
        
            node.append(key: parent.keys[parentNum], value: parent.values[parentNum])
            parent.replace(index: parentNum, key: sibling.keys[0], value: sibling.values[0])
            sibling.removeKV(index: 0)
            
            if node.childrens != nil{
                let child = sibling.childrens![0]!
                sibling.removeChildAtIndex(index: 0)
                node.appendChild(child: child)
            }
        
        }
        
    }
    
    // MARK:
    // MARK: Helper
    
    /// predecesor of node
    fileprivate func predesesor(node:BTreeNode<K,V>)->BTreeNode<K,V>{
        guard node.childrens != nil else {
            return node
        }
        return predesesor(node: node.childrens![node.childrens!.count - 1]!)
    }
    
}
