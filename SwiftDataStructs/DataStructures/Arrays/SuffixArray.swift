//
//  SuffixArray.swift
//  swiftTest
//
//  Created by Tomislav Profico on 09/03/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class SuffixArrayNode : Comparable {
    var index:Int
    var suffix:String
    
    init(suffix:String, index:Int) {
        self.suffix = suffix
        self.index = index
    }
    
    static func == (lhs: SuffixArrayNode, rhs: SuffixArrayNode) -> Bool {
        return (lhs.suffix.hasPrefix(rhs.suffix))
    }
    
    static func < (lhs: SuffixArrayNode, rhs:SuffixArrayNode) -> Bool {
        return lhs.suffix < rhs.suffix
    }
}

class SuffixArray {

    var suffixes : Array<String>?
    fileprivate var orderedData : Array<SuffixArrayNode>?
    
    ///init suffix array from suffix tree
    init(suffixTree:SuffixTree) {
        let visitor = VisitTree.init(count: suffixTree.count())
        suffixTree.visitSuffixes(visitor: visitor)
        self.suffixes = visitor.suffixes
        self.orderedData = visitor.sortedArray
    }
    
    ///init with string
    init(string:String) {
    
        buildArray(string: string)
    }
    
    ///build suffix array from string
    ///
    /// - parameter string: string which suffix we build
    fileprivate func buildArray(string:String){
        
        suffixes = []
        orderedData = []
    
        for i in 0..<string.count{
        
            let range = string.index(string.startIndex, offsetBy: i)..<string.index(string.endIndex, offsetBy: 0)
            let suffix = String(string[range])
            suffixes!.append(suffix)
            orderedData!.append(SuffixArrayNode.init(suffix: suffix, index: i))
        }
        
        orderedData = orderedData!.sorted { (s1, s2) -> Bool in
            s1.suffix < s2.suffix
        }
    }
    
    ///Does search substring exist. Use Binary search to search suffixes.
    ///
    /// - parameter patternString: substring we check
    ///
    /// - return does substring exist
    func searchForSubstring(patternString:String)->Bool{
        
        guard self.orderedData != nil else {
            return false
        }
    
        let index = BinarySearch<SuffixArrayNode>().binarySearch(data: self.orderedData!, searchedValue: SuffixArrayNode.init(suffix: patternString, index: -1))
        
        return index != nil
    }
    
    ///If substring exist return first position, else return nil, also use binary search to find substring.
    ///
    /// - parameter patternString: substring we check
    ///
    /// - return index of first charachter of string if exist
    func searchForSubstringPosition(patternString:String)->Int?{
        
        guard self.orderedData != nil else {
            return nil
        }
        
        let index = BinarySearch<SuffixArrayNode>().binarySearch(data: self.orderedData!, searchedValue: SuffixArrayNode.init(suffix: patternString, index: -1))
        
        guard index != nil else {
            return nil
        }
        
        return orderedData![index!].index
    }
    
    ///If substring exist return all positions of first charachter, else return nil, also use binary search to find substring.
    ///
    /// - parameter patternString: substring we check
    ///
    /// - return indexes of first charachter of string if exist
    func searchForAllSubstringPosition(patternString:String)->[Int]?{
        
        guard self.orderedData != nil else {
            return nil
        }
        
        let index = BinarySearch<SuffixArrayNode>().binarySearch(data: self.orderedData!, searchedValue: SuffixArrayNode.init(suffix: patternString, index: -1))
        
        guard index != nil else {
            return nil
        }
        
        var result = [orderedData![index!].index]
        var helper = index! + 1
        while helper >= 0 && helper < orderedData!.count {
            if orderedData![helper].suffix.hasPrefix(patternString){
                result.append(orderedData![helper].index)
                helper += 1
            }else{
                break
            }
        }
        
        helper = index! - 1
        while helper >= 0 && helper < orderedData!.count {
            if orderedData![helper].suffix.hasPrefix(patternString){
                result.append(orderedData![helper].index)
                helper -= 1
            }else{
                break
            }
        }
        
        return result
    }
    
    ///Longest repeating substring of array. Check if two neighboor share common prefix, if yes check if we have longer string stored, if no store this substring
    ///
    /// - return longest substring of array
    func longestRepeatingSubstring() -> String?{
        
        guard orderedData != nil else {
            return nil
        }
        var currentRes = ""
        for i in 0..<orderedData!.count - 1{
    
            let pref = orderedData![i].suffix.commonPrefix(with: orderedData![i + 1].suffix)
            if pref.count > currentRes.count{
                currentRes = pref
            }
        }
        return currentRes
    }
}

class VisitTree : Visitor<(suffix:String, index:Int)>{

    var sortedArray:[SuffixArrayNode] = []
    var suffixes : Array<String>
    var count : Int
    
    init(count:Int) {
        self.count = count
        suffixes = Array<String>.init(repeating: "", count: count)
    }
    
    override func visit(object: (suffix: String, index: Int)) {
        
        guard object.suffix.isEmpty != true else{
            return
        }
    
        suffixes[object.index] = object.suffix
        let node = SuffixArrayNode.init(suffix: object.suffix, index: object.index)
        sortedArray.insertElement(element: node) { (n1, n2) -> Bool in
            n1.suffix < n2.suffix
        }
    }
}

