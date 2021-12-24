//
//  MedianHeap.swift
//  swiftTest
//
//  Created by Tomislav Profico on 03/04/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class MedianHeap<T : Comparable> {
    
    fileprivate var minHeap : Heap<T>
    fileprivate var maxHeap : Heap<T>
    fileprivate var average : (T,T)->T
    
    var count : Int{
        get{
            return minHeap.count() + maxHeap.count()
        }
    }
    
    init(average:@escaping (T,T)->T) {
        self.minHeap = Heap<T>.init(orderFunction: <)
        self.maxHeap = Heap<T>.init(orderFunction: >)
        self.average = average
    }
    
    func insert(value : T){
    
        if maxHeap.isEmpty(){
            maxHeap.insert(value: value)
        }else if maxHeap.peek()! > value{
            if minHeap.isEmpty() || (maxHeap.count() >  minHeap.count() && maxHeap.peek()! > value){
                let v = maxHeap.extract()
                minHeap.insert(value: v!)
                maxHeap.insert(value: value)
            }else if maxHeap.count() <=  minHeap.count(){
                maxHeap.insert(value: value)
            }else if maxHeap.peek()! <= value{
                minHeap.insert(value: value)
            }
        }else if maxHeap.peek()! < value{
            if maxHeap.count() >  minHeap.count(){
                minHeap.insert(value: value)
            }else if (minHeap.peek()! > value){
                maxHeap.insert(value: value)
            }else{
                let v = minHeap.extract()
                maxHeap.insert(value: v!)
                minHeap.insert(value: value)
            }
        }
    }
    
    func peekMedian()->T?{
        guard count != 0 else {
            return nil
        }
        
        if maxHeap.count() > minHeap.count(){
            return maxHeap.peek()
        }else if maxHeap.count() < minHeap.count(){
            return minHeap.peek()!
        }else{
            return average(minHeap.peek()!, maxHeap.peek()!)
        }
    }
}
