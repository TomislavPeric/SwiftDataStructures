//
//  LFUCache.swift
//  swiftTest
//
//  Created by Tomislav Profico on 13/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class LFUCacheNode<T> : Equatable, Hashable{

    var value: T
    var key: String
    var count: Int
    
    init(key:String, value:T, count:Int) {
        self.key = key
        self.value = value
        self.count = count
    }
    
    static func == (lhs: LFUCacheNode<T>, rhs: LFUCacheNode<T>) -> Bool {
        return lhs.key == rhs.key
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(key.hash)
    }
}

class LFUCache<T> {
    
    /// number of object stored in memory
    fileprivate var capacity:Int
    
    /// We implement LFU cache using priority and hashMap
    fileprivate var queue:PriorityQueue<LFUCacheNode<T>>
    fileprivate var map:[String:LFUCacheNode<T>]
    
    init(capacity:Int) {
        self.capacity = capacity
        queue = PriorityQueue<LFUCacheNode<T>>.init(orderFunction: { (t1, t2) -> Bool in
            t1.count <= t2.count
        })
        map = [:]
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
    
    /// get value for searching key. If exist increase his count number, else return nil
    /// running time: O(log(n))
    ///
    /// - parameter key: key for which we search stored value
    /// - return: stored value
    func get(key:String)->T?{
        if let oldElement = map[key]{
            let newElement = LFUCacheNode<T>.init(key: key, value: oldElement.value, count: oldElement.count + 1)
            queue.changePriority(newElement: newElement, oldElement: oldElement)
            map[key] = newElement
            return oldElement.value
        }else{
            return nil
        }
    }
    
    /// set value for input key
    /// running time: O(log(n))
    ///
    /// - parameter key: key for which we search stored value
    /// - parameter value: value we want insert for given key
    func set(key:String, value:T){
        if let oldElement = map[key]{
            let newElement = LFUCacheNode<T>.init(key: key, value: value, count: oldElement.count + 1)
            queue.changePriority(newElement: newElement, oldElement: oldElement)
        }else {
            if queue.count() == capacity{
                let keyDeleted = queue.extract()
                map.removeValue(forKey: keyDeleted?.key ?? "")
            }
            let node = LFUCacheNode.init(key: key, value: value, count: 1)
            map[key] = node
            queue.insert(value: node)
        }
    }
}
