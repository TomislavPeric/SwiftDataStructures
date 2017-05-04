//
//  LRUCache.swift
//  swiftTest
//
//  Created by Tomislav Profico on 13/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class LRUCache<T> {
    
    /// number of object stored in memory
    fileprivate var capacity:Int
    
    /// We implement LRU cache using double link list and hashMap
    fileprivate var linkList:DoubleEndedLinkedList<String>
    fileprivate var map:[String:T]
    
    /// init must send capacity parameter
    init(capacity:Int) {
        self.capacity = capacity
        self.linkList = DoubleEndedLinkedList<String>.init(twoValueEquelFunction: { (t1, t2) -> Bool in
            t1 == t2
        })
        self.map = [:]
    }
    
    /// subscribe we can set value for key or get some value that is stored for that key
    subscript(key: String) -> T? {
        get {
            return get(key: key)
        }
        set(newValue) {
            if newValue != nil{
                set(key: key, value: newValue!)
            }
        }
    }
    
    /// get value for searching key, if exist
    /// running time: O(n) (worse case)
    ///
    /// - parameter key: key for which we search stored value
    /// - return: stored value
    func get(key:String)->T?{
        if let value = map[key]{
            linkList.moveValueToFront(value: key)
            return value
        }
        return nil
    }
    
    /// set value for input key
    /// running time: O(n) (worse case)
    ///
    /// - parameter key: key for which we search stored value
    /// - parameter value: value we want insert for given key
    func set(key:String, value:T){
        
        if map[key] != nil{
            linkList.moveValueToFront(value: key)
        }else {
            if linkList.size == capacity{
                let keyDeleted = linkList.lastNode?.value ?? ""
                map.removeValue(forKey: keyDeleted)
                _ = linkList.removeLast()
            }
            map[key] = value
            linkList.insertFirst(value: key)
        }
    }
}
