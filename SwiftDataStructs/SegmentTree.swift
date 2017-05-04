//
//  SegmentTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 07/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class SegmentTree<T> : NSObject {
    
    internal var originalArray:[T]
    internal var segmentTreeArray:[T?]
    internal var function : (T,T)->T
    
    convenience init(function:@escaping (T,T)->T) {
        self.init(function:function,array:[])
    }
    
    init(function:@escaping (T,T)->T,array:[T]) {
        self.function = function
        self.originalArray = array
        self.segmentTreeArray = []
        super.init()
        self.segmentTreeArray = Array<T?>.init(repeating: nil, count: self.sizeOfArray())
        self.constructTree(low: 0, high: self.originalArray.count - 1, pos: 0)
    }
    
    // MARK:
    // MARK: Construct
    
    /// construct tree from original array. Go recursicly for each branch and if low boundery equel high boudery set to new value to tree, else calculate value base of children vlue on function from init method.
    /// running time: O(n)
    ///
    /// - parameter low and high: bounderies
    /// - parameter pos: current position
    fileprivate func constructTree(low:Int,high:Int,pos:Int){
    
        if low == high{
        
            segmentTreeArray[pos] = originalArray[low]
            return
        }
        
        let mid = (low + high) / 2
        
        constructTree(low: low, high: mid, pos: leftChildIndex(index: pos))
        constructTree(low: mid + 1, high: high, pos: rightChildIndex(index: pos))
        segmentTreeArray[pos] = function(segmentTreeArray[leftChildIndex(index: pos)]!, segmentTreeArray[rightChildIndex(index: pos)]!)
    
    }
    
    // MARK:
    // MARK: Query
    
    /// query for range
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: min range boundery
    /// - parameter toIndex: max range boundery
    ///
    /// - return result from given range
    func rangeQuery(fromIndex:Int,toIndex:Int)->T?{
        
        assert(fromIndex >= 0, "From index must bew positiv")
        assert(toIndex < originalArray.count,"toIndex out of bounds")
        
        return query(fromIndex: fromIndex, toIndex: toIndex, low: 0, high: originalArray.count - 1, pos: 0)
    }
    
    /// query for range helper private method.
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: min range boundery
    /// - parameter toIndex: max range boundery
    /// - parameters low, high, pos: helpers
    ///
    /// - return result from given range
    fileprivate func query(fromIndex:Int,toIndex:Int,low:Int,high:Int,pos:Int)->T?{
        
        if(fromIndex <= low && toIndex >= high){
            return segmentTreeArray[pos];
        }
        if(fromIndex > high || toIndex < low){
            return nil;
        }
        
        let mid = (low + high) / 2
        
        let a = query(fromIndex:fromIndex, toIndex:toIndex, low:low,high: mid,pos: leftChildIndex(index: pos))
        let b = query(fromIndex:fromIndex, toIndex:toIndex, low:mid + 1,high: high,pos: rightChildIndex(index: pos))
        
        if a == nil && b == nil{
            return nil
        }else if a == nil{
            return b
        }else if b == nil{
            return a
        }else{
            return function(a!,b!)
        }
    }
    
    // MARK:
    // MARK: Update
    
    /// update tree with changing original array with new value at index.
    /// running time: O(log(n))
    ///
    /// - parameter index: original array index that need to be updated
    /// - parameter newValue: new value
    func update(index:Int,newValue:T){
        
        assert(index < originalArray.count, "Index updated out of bounds")
        
        originalArray[index] = newValue
        updateSegmentTree(index:index,newValue:newValue,low:0,high:originalArray.count - 1,pos:0)
    }
    
    /// update tree with changing original array with new value at index.
    /// running time: O(log(n))
    ///
    /// - parameter index: original array index that need to be updated
    /// - parameter newValue: new value
    /// - parameters low, high, pos: helpers
    fileprivate func updateSegmentTree(index:Int,newValue:T,low:Int,high:Int,pos:Int){
        
        if index < low || index > high{
            return
        }
        
        if(low == high){
            segmentTreeArray[pos] = newValue
            return
        }
        
        let mid = (low + high)/2
        
        updateSegmentTree(index:index,newValue:newValue,low:low,high: mid,pos:leftChildIndex(index: pos))
        updateSegmentTree(index:index,newValue:newValue,low:mid + 1,high: high,pos:rightChildIndex(index: pos))
        segmentTreeArray[pos] = function(segmentTreeArray[leftChildIndex(index: pos)]!, segmentTreeArray[rightChildIndex(index: pos)]!)
    }
    
    /// update range fromIndex to index using delta function
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: start index of segment
    /// - parameter toIndex: end index of segment
    /// - parameter deltaFunction: function that determinate difference from old to new value
    func updateRange(fromIndex:Int, toIndex:Int,deltaFunction:@escaping (T?)->T){
        
        assert(fromIndex >= 0, "From index must bew positiv")
        assert(toIndex < originalArray.count,"toIndex out of bounds")
        
        updateRange(fromIndex: fromIndex, toIndex: toIndex, deltaFunction: deltaFunction, low: 0, high: originalArray.count - 1, pos: 0)
    }
    
    /// update range fromIndex to index using delta function
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: start index of segment
    /// - parameter toIndex: end index of segment
    /// - parameter deltaFunction: function that determinate difference from old to new value
    /// - parameters low, high, pos: helpers
    fileprivate func updateRange(fromIndex:Int, toIndex:Int,deltaFunction:@escaping (T?)->T, low:Int, high:Int, pos:Int){
        
        if(low > high || fromIndex > high || toIndex < low ) {
            return;
        }
        
        if(low == high) {
            segmentTreeArray[pos] = deltaFunction(segmentTreeArray[pos])
            return;
        }
        
        let mid = (low + high)/2
        
        updateRange(fromIndex: fromIndex, toIndex: toIndex, deltaFunction: deltaFunction, low:low, high:mid, pos:leftChildIndex(index: pos))
        updateRange(fromIndex: fromIndex, toIndex: toIndex, deltaFunction: deltaFunction, low:mid + 1, high:high, pos:rightChildIndex(index: pos))
        segmentTreeArray[pos] = function(segmentTreeArray[leftChildIndex(index: pos)]!,segmentTreeArray[rightChildIndex(index: pos)]!)
    }
    
    
    
    
    // MARK:
    // MARK: Helpers
    
    internal func parentIndex(index:Int)->Int{
        return (index - 1) / 2
    }
    
    internal func leftChildIndex(index:Int)->Int{
        return (index * 2) + 1
    }
    
    internal func rightChildIndex(index:Int)->Int{
        return (index * 2) + 2
    }
    
    internal func sizeOfArray()->Int{
        return  2 * Int(pow(2, ceil(log(Double(originalArray.count))/log(Double(2))))) - 1
    }
    
}
