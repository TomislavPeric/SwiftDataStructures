//
//  SplayCache.swift
//  swiftTest
//
//  Created by Tomislav Profico on 17/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit
import ObjectiveC

private var xoAssociationKey: UInt8 = 0

///Adding new property to node
///
internal extension BinarySearchTreeNode {
    var storedValue: Any! {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

class SplayCache<K : Comparable,T> {
    
    /// number of object stored in memory
    fileprivate var capacity:Int
    
    fileprivate var tree:SplayTree<K>
    
    init(capacity:Int) {
        self.capacity = capacity
        tree = SplayTree<K>()
    }
    
    /// subscribe we can set value for key or get some value that is stored for that key
    subscript(key: K) -> T? {
        get {
            return get(key: key)
        }
        set(newValue) {
            if newValue != nil{
                set(key: key, value: newValue!)
            }
        }
    }
    
    /// get value for searching key. If exist increase his count number, else return nil
    /// running time: O(log(n))
    ///
    /// - parameter key: key for which we search stored value
    /// - return: stored value
    func get(key:K)->T?{
        let node = tree.select(value: key)
        return node?.storedValue as! T?
    }
    
    /// set value for input key
    /// running time: O(log(n))
    ///
    /// - parameter key: key for which we search stored value
    /// - parameter value: value we want insert for given key
    func set(key:K, value:T){
        let node = tree.select(value: key)
        if node == nil{
            let newNode = tree.insert(value: key)
            newNode.storedValue = value
            
            if capacity < tree.size{
                let value = findButtomNode(node: tree.rootNode)
                if value != nil{
                    _ = tree.delete(value: value!)
                }
            }
            
        }else{
            node!.storedValue = value
        }
    }
    
    
    fileprivate func findButtomNode(node:BinarySearchTreeNode<K>?)->K?{
    
        guard node != nil else {
            return nil
        }
        
        let leftHeight = node!.leftChild?.leftSubtreeHeight ?? -1
        let rightHeight = node!.rightChild?.leftSubtreeHeight ?? -1
        
        if leftHeight == -1 && rightHeight == -1{
            return node!.value
        }else if leftHeight >= rightHeight{
            return findButtomNode(node: node!.leftChild)
        }else{
            return findButtomNode(node: node!.rightChild)
        }
    }

}
