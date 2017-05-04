//
//  BinarySearch.swift
//  swiftTest
//

import UIKit

class BinarySearch<V :Comparable>{
    
    public func binarySearch(data: [V], searchedValue: V) -> Int? {
        var low = 0
        var up = data.count
        while low < up {
            let mid = low + (up - low) / 2
            if data[mid] == searchedValue {
                return mid
            } else if data[mid] < searchedValue {
                low = mid + 1
            } else {
                up = mid
            }
        }
        return nil
    }

}
