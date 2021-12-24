//
//  RadixSort.swift
//  swiftTest
//

import UIKit

class RadixSort<T> {

    fileprivate var originalData : [T]
    fileprivate var sortedData : [T]
    fileprivate var buckets : Array<[T]>
    fileprivate var charachterIndexFunc : (T, Int, Int)->T
    fileprivate var uniqueValueOfIndex  : (T)->Int
    fileprivate var countOfCharachters  : (T)->Int
    fileprivate var radix : Int
    fileprivate var maxChar = 0
    
    init(dataToSort:[T], numberOfLatters:Int, charachterIndex:@escaping (T, Int, Int)->T, uniqueValueOfIndex:@escaping (T)->Int, countOfCharachters:@escaping (T)->Int) {
        self.originalData = dataToSort
        self.buckets = Array<[T]>.init(repeating: [], count: numberOfLatters)
        self.radix = numberOfLatters
        self.charachterIndexFunc = charachterIndex
        self.uniqueValueOfIndex = uniqueValueOfIndex
        self.countOfCharachters = countOfCharachters
        self.sortedData = originalData
        for t in sortedData{
            if countOfCharachters(t) > maxChar{
                maxChar = countOfCharachters(t)
            }
        }
        sort()
    }
    
    func sorted()->[T]{
        return self.sortedData
    }
    
    fileprivate func sort(){
        
        var current = 0
        while true {
            
            for t in sortedData{
                let char = charachterIndexFunc(t, current, maxChar)
                let index = uniqueValueOfIndex(char)
                assert(index < radix, "index for charachter out of bounds")
                buckets[index].append(t)
                
                
            }
            
            sortedData.removeAll()
            
            for i in 0..<buckets.count{
                let bucket = buckets[i]
                for data in bucket{
                    sortedData.append(data)
                }
                buckets[i].removeAll()
            }
        
            current += 1
            if current >= maxChar{
                break
            }
        }
        
        
    }
    
}
