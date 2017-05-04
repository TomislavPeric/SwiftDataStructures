//
//  SortedArray.swift
//  swiftTest
//
//  Created by Tomislav Profico on 07/03/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

extension Array {
    mutating func insertElement(element: Element, orderFunction: (Element, Element) -> Bool) {
        var low = 0
        var high = self.count - 1
        while low <= high {
            let mid = (low + high)/2
            if orderFunction(self[mid], element) {
                low = mid + 1
            } else if orderFunction(element, self[mid]) {
                high = mid - 1
            } else {
                insert(element, at: mid)
                return
            }
        }
        insert(element, at: low)
    }
    
    mutating func insertWithNoRepaeatingElement(element: Element, orderFunction: (Element, Element) -> Bool) {
        var low = 0
        var high = self.count - 1
        while low <= high {
            let mid = (low + high)/2
            if orderFunction(self[mid], element) {
                low = mid + 1
            } else if orderFunction(element, self[mid]) {
                high = mid - 1
            } else {
                //insert(element, at: mid)
                return
            }
        }
        insert(element, at: low)
    }
    
}
