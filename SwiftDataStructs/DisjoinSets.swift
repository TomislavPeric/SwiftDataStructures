//
//  DisjoinSets.swift
//  swiftTest
//
//  Created by Tomislav Profico on 22/03/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class DisjoinSetsNode<T>{

    var value: T
    var rank: Int
    var parent : DisjoinSetsNode<T>?
    var childs : [DisjoinSetsNode<T>] = []
    
    init(value: T, rank:Int) {
        self.value = value
        self.rank = rank
    }
    
}

class DisjoinSets<T : Hashable> {

    fileprivate var map : [T : DisjoinSetsNode<T>] = [:]
    
    var numberOfSets : Int = 0
    
    func makeSet(array:[T]){
    
        map.removeAll()
        numberOfSets = array.count
        for a in array{
            let node = DisjoinSetsNode<T>.init(value: a, rank: 0)
            node.parent = node
            map[a] = node
        }
    }
    
    
    func findSet(value:T)->T?{
    
        let node = map[value]
        
        guard node != nil else {
            return nil
        }
        
        return findSet(node: node!).value
    }
    
    func union(value1:T, value2:T){
    
        let node1 = map[value1]
        let node2 = map[value2]
        
        guard node1 != nil && node2 != nil else {
            return
        }
        
        let set1 = findSet(node: node1!)
        let set2 = findSet(node: node2!)
        
        if set1.value == set2.value{
            return
        }
        numberOfSets -= 1
        if set1.rank > set2.rank{
            set2.parent = set1
            set1.childs.append(set2)
            set1.childs.append(contentsOf: set2.childs)
            set2.childs = []
        }else if set1.rank < set2.rank{
            set1.parent = set2
            set2.childs.append(set1)
            set2.childs.append(contentsOf: set1.childs)
            set1.childs = []
        }else{
            set2.parent = set1
            set1.rank += 1
            set1.childs.append(set2)
            set1.childs.append(contentsOf: set2.childs)
            set2.childs = []
        }
        
    }
    
    fileprivate func findSet(node:DisjoinSetsNode<T>)->DisjoinSetsNode<T>{
        
        if node.parent === node{
            return node
        }
    
        node.parent = findSet(node: node.parent!)
        return node.parent!
    }
    
    func allValuesForSet(value:T)->[T]?{
    
        let node1 = map[value]
        
        guard node1 != nil else{
            return nil
        }
        
        let set1 = findSet(node: node1!)
        
        var result : [T] = []
        
        result.append(set1.value)
        
        for child in set1.childs{
            result.append(child.value)
        }
        
        return result
    }
    
    func allSets()->[[T]]?{
    
        guard !map.isEmpty else {
            return nil
        }
        
        var data : [T:[T]] = [:]
        var result : [[T]] = []
        for m in map.keys{
            
            let parent = findSet(value: m)!
            if data[parent] == nil{
                data[parent] = []
            }
            data[parent]!.append(m)
        }
        
        for d in data.values{
            result.append(d)
        }
        
        return result
    }
}
