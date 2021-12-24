//
//  NextLexicographicalPermutation.swift
//  swiftTest
//
//  Created by Tomislav Profico on 09/05/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class NextLexicographicalPermutation<T : Comparable> {
    
    func nextPermutation(data: [T]) -> [T]?{
    
        var array = data
        var i = array.count - 1
        
        while (i > 0 && array[i - 1] >= array[i]){
            i -= 1
        }
        
        if (i <= 0){
            return nil
        }
        
        
        var j = array.count - 1
        
        while (array[j] <= array[i - 1]){
            j -= 1
        }
        
        var temp = array[i - 1]
        array[i - 1] = array[j]
        array[j] = temp;
        
        j = array.count - 1
        while (i < j) {
            temp = array[i]
            array[i] = array[j]
            array[j] = temp
            i += 1
            j -= 1
        }
        
        return array
    }
}
