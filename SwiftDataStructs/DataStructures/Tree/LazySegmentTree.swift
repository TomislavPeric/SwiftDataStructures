//
//  LazySegmentTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 20/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class LazySegmentTree<T>: SegmentTree<T> {
    
    fileprivate var lazyTree:[T?]
    internal var deltaFunction : (T?, T?)->T
    
    init(function: @escaping (T, T) -> T, array: [T], deltaFunction:@escaping (T?, T?)->T) {
        self.lazyTree = []
        self.deltaFunction = deltaFunction
        super.init(function: function, array: array)
        self.lazyTree = Array<T?>.init(repeating: nil, count: self.sizeOfArray())
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
    override func rangeQuery(fromIndex: Int, toIndex: Int) -> T? {
        return lazyRangeQuery(fromIndex: fromIndex, toIndex: toIndex, low: 0, high: originalArray.count - 1, pos: 0)
    }
    
    /// query for range helper private method.
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: min range boundery
    /// - parameter toIndex: max range boundery
    /// - parameters low, high, pos: helpers
    ///
    /// - return result from given range
    fileprivate func lazyRangeQuery(fromIndex: Int, toIndex: Int, low:Int, high:Int, pos:Int) ->T?{
        
        if(low > high) {
            return nil;
        }
        if (lazyTree[pos] != nil){
            segmentTreeArray[pos] = deltaFunction(segmentTreeArray[pos], lazyTree[pos])
            
            if low != high{
                lazyTree[leftChildIndex(index: pos)] = deltaFunction(lazyTree[leftChildIndex(index: pos)],lazyTree[pos])
                lazyTree[rightChildIndex(index: pos)] = deltaFunction(lazyTree[rightChildIndex(index: pos)],lazyTree[pos])
            }
            lazyTree[pos] = nil
        }
        
        if fromIndex > high || toIndex < low{
            return nil
        }
        
        if fromIndex <= low && toIndex >= high{
            return segmentTreeArray[pos]
        }
        
        let mid = (low + high) / 2
        
        let a = lazyRangeQuery(fromIndex: fromIndex, toIndex: toIndex, low: low, high: mid, pos: leftChildIndex(index: pos))
        let b = lazyRangeQuery(fromIndex: fromIndex, toIndex: toIndex, low: mid + 1, high: high, pos: rightChildIndex(index: pos))
        
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
    override func update(index: Int, newValue: T) {
        lazyUpdateRange(fromIndex: index, toIndex: index, deltaFunction: { (t1) -> T in
            return newValue
        }, low: 0, high: originalArray.count - 1, pos: 0)
    }
    
    /// update range fromIndex to index using delta function
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: start index of segment
    /// - parameter toIndex: end index of segment
    /// - parameter deltaFunction: function that determinate difference from old to new value
    override func updateRange(fromIndex: Int, toIndex: Int, deltaFunction: @escaping (T?) -> T) {
        lazyUpdateRange(fromIndex: fromIndex, toIndex: toIndex, deltaFunction: deltaFunction, low: 0, high: originalArray.count - 1, pos: 0)
    }
    
    /// update range fromIndex to index using delta function
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: start index of segment
    /// - parameter toIndex: end index of segment
    /// - parameter deltaFunction: function that determinate difference from old to new value
    /// - parameters low, high, pos: helpers
    fileprivate func lazyUpdateRange(fromIndex: Int, toIndex: Int, deltaFunction: @escaping (T?) -> T, low:Int, high:Int, pos:Int){
    
        if(low > high) {
            return
        }
        
        if (lazyTree[pos] != nil) {
            segmentTreeArray[pos] = self.deltaFunction(segmentTreeArray[pos], lazyTree[pos])
            if (low != high) {
                lazyTree[leftChildIndex(index: pos)] = self.deltaFunction(lazyTree[leftChildIndex(index: pos)], lazyTree[pos])
                lazyTree[rightChildIndex(index: pos)] = self.deltaFunction(lazyTree[rightChildIndex(index: pos)], lazyTree[pos])
            }
            lazyTree[pos] = nil;
        }
        
        if(fromIndex > high || toIndex < low) {
            return;
        }
        
        if(fromIndex <= low && toIndex >= high) {
            segmentTreeArray[pos] = deltaFunction(segmentTreeArray[pos])
            if(low != high) {
                lazyTree[leftChildIndex(index: pos)] = deltaFunction(lazyTree[leftChildIndex(index: pos)])
                lazyTree[rightChildIndex(index: pos)] = deltaFunction(lazyTree[rightChildIndex(index: pos)])
            }
            return;
        }
        
        let mid = (low + high) / 2
        
        lazyUpdateRange(fromIndex: fromIndex, toIndex: toIndex, deltaFunction: deltaFunction, low: low, high: mid, pos: leftChildIndex(index: pos))
        lazyUpdateRange(fromIndex: fromIndex, toIndex: toIndex, deltaFunction: deltaFunction, low: mid + 1, high: high, pos: rightChildIndex(index: pos))
        segmentTreeArray[pos] = self.function(segmentTreeArray[leftChildIndex(index: pos)]!,segmentTreeArray[rightChildIndex(index: pos)]!)
        
    } 
}
