//
//  HeapWithChangableElements.swift
//  swiftTest
//

import UIKit

class HeapWithChangableElements<T :Hashable>: Heap<T> {
    
    // extra hash map that store current index of some value
    fileprivate var map : [T : [Int]] = [:]
    
    override init(orderFunction:@escaping (T,T)->Bool) {
        super.init(orderFunction: orderFunction)
    }
    
    fileprivate func setValueToMap(key:T, value:Int){
    
        if map[key] == nil{
            map[key] = [value]
        }else{
            map[key]!.append(value)
        }
    }
    
    fileprivate func removeValueFromMap(key:T, value:Int){
    
        if map[key] == nil{
            return
        }
        
        if map[key]!.count == 1{
            map[key] = nil
        }else{
            map[key]!.remove(at: map[key]!.firstIndex(of: value)!)
        }
    }

    // override hepify method and add all value in array to map, then call super method.
    override func heapify(array: [T]) {
        
        for i in 0..<array.count{
            setValueToMap(key: array[i], value: i)
        }
        
        super.heapify(array: array)
    }
    
    // override insert method and add value in map, then call super method.
    override func insert(value: T) {
        setValueToMap(key: value, value: elements.count)
        super.insert(value: value)
    }
    
    // override extract method get extracted value from super method, remove that value from map and return extracted value.
    override func extract() -> T? {
        
        guard elements.count > 0 else {
            return nil
        }
        removeValueFromMap(key: elements[0], value: 0)
         removeValueFromMap(key: elements[count() - 1], value: count() - 1)
        
        let t = super.extract()
        
        guard t != nil else {
            return nil
        }
        
        return t
    }
    
    // override swapElementsatIndexes method. Every time values are swaped swaped they indexes in map.
    override func swapElementsatIndexes(index1:Int, index2:Int){
        removeValueFromMap(key: elements[index1], value: index1)
        removeValueFromMap(key: elements[index2], value: index2)
        setValueToMap(key: elements[index1], value: index2)
        setValueToMap(key: elements[index2], value: index1)
        super.swapElementsatIndexes(index1:index1, index2:index2)
    }
    
    override func setElement(index:Int,element:T,from:Int){
        setValueToMap(key: element, value: index)
        super.setElement(index:index, element:element, from:from)
    }
    
    // change value of some node
    public func changePriority(newElement: T,oldElement: T){
        
        let value = map[oldElement]
        if value != nil{
            let index = value!.first!
            elements[index] = newElement
            if value!.first! != 0 && orderFunction(elements[index],elements[parentIndex(index:index)]){
                checkMoveUp(index:index)
            }else{
                checkMoveDown(index:index)
            }
        }
    }
    
    /// remove value from heap
    ///
    /// - parameter value: value removed from heap
    ///
    /// - return if value is removed from heap
    @discardableResult
    func remove(value: T)->Bool{
    
        let index = map[value]
        
        guard index != nil else {
            return false
        }
        
        guard elements.count != 1 else {
            return extract() != nil
        }
        
        let first = index!.first!
        
        guard first != count() - 1 else {
            removeValueFromMap(key: value, value: first)
            elements.removeLast()
            return true
        }
        
        swapElementsatIndexes(index1: first, index2: elements.count - 1)
        removeValueFromMap(key: value, value: elements.count - 1)
        elements.removeLast()
        guard first < count() else {
            return true
        }
        if first != 0 && orderFunction(elements[first],elements[parentIndex(index:first)]){
            checkMoveUp(index:first)
        }else{
            checkMoveDown(index:first)
        }
        
        return true
    }
    
    // if heap contains value
    func contains(value:T)->Bool{
    
        return map[value] != nil
    }
    
}
