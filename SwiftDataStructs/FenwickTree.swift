//
//  FenwickTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 04/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//A Fenwick tree or binary indexed tree is a data structure providing efficient methods
// for calculation and manipulation of the prefix sums of a table of values.
/* References
     http://www.geeksforgeeks.org/binary-indexed-tree-or-fenwick-tree-2/
 https://www.topcoder.com/community/data-science/data-science-tutorials/binary-indexed-trees/
 http://en.wikipedia.org/wiki/Fenwick_tree
 https://www.youtube.com/watch?v=CWDQJGaN1gY
*/

import UIKit

class FenwickTree {
    
    // new calculated array based on which we calculating prefix sum
    fileprivate var fenwickTree : [Int]?
    
    // stored original array
    fileprivate var array : [Int]?
    
    // MARK:
    // MARK: Creation
    
    init(array:[Int]) {
        self.createTree(array: array)
    }
    
    init() {
        
    }
    
    /// If we use jus init() we need manualy create tree sending array for which we creating tree, if we use init(array:[Int]) then ther eis no need to call this method.
    /// This methode store original array and create fenwick tree array which have saize originalArray.size + 1 and initial value are 0 for every element, then for each array element we call buildTree method
    /// running time: O(n*log(n))
    ///
    /// - parameter array: original array
    func createTree(array:[Int]){
        self.array = array
        fenwickTree = Array<Int>.init(repeating: 0, count: array.count + 1)
        for index in 0..<array.count{
            buildTree(index: index)
        }
    }
    
    /// First we get original array value at index, then we starting with index + 1 searching for all fenwick element that will be added value from original array, using getNext method.
    /// running time: O(log(n))
    ///
    /// - parameter index: index of original array which value is added to specific indexes ad fenwick array
    fileprivate func buildTree(index:Int){
        
        var i = index + 1
        
        while i < fenwickTree!.count{
            fenwickTree![i] = fenwickTree![i] + array![index]
            i = getNext(index: i)
        }
    }
    
    // MARK:
    // MARK: Update
    
    /// Update original array with new value. Calculating difference beetwen new and old value and changing with this differenc all fenwick element that is efected with this index.
    /// running time: O(log(n))
    ///
    /// - parameter value: value that need to be update
    /// - parameter value: index that need to be update
    func update(value:Int,index:Int){
    
        assert(array != nil, "Tree is not created yet")
        assert(index < array!.count, "Index out of bounds")
        
        let diff = value - array![index]
        updateTree(index: index, diff: diff)
    }
    
    /// Update  all fenwick element that is efected with this index, with diff value.
    /// running time: O(log(n))
    ///
    /// - parameter index: index for which we calculating fenwick array indexes which need to be recalculating
    /// - parameter diff: value need to be added to fenwick tree efected indexes
    fileprivate func updateTree(index:Int, diff:Int){
        
        var i = index + 1
        
        while i < fenwickTree!.count{
            fenwickTree![i] = fenwickTree![i] + diff
            i = getNext(index: i)
        }
        
    }
    
    // MARK:
    // MARK: Search
    
    /// If fromIndex is 0 then just return value from getSum method, else calculate prefix sum use formula: getSum(toIndex) - getSum(fromIndex - 1)
    /// running time: O(log(n))
    ///
    /// - parameter fromIndex: first index from we calculating sum of original array
    /// - parameter toIndex: last index from we calculating sum of original array
    ///
    /// - return: prefix sum
    func getPrefixSum(fromIndex:Int,toIndex:Int)->Int{
    
        assert(array != nil, "Tree is not created yet")
        assert(fromIndex >= 0, "fromIndex is less then 0")
        assert(fromIndex < array!.count, "fromIndex is out of bounds")
        assert(toIndex >= fromIndex, "toIndex is less then fromIndex")
        assert(toIndex < array!.count, "toIndex is out of bounds")
        
        if fromIndex == 0{return getSum(index: toIndex)}
        else {return getSum(index: toIndex) - getSum(index: fromIndex - 1)}
    }
    
    /// Calculaing prefix sum from zero to index. We get fenwick tree element as index + 1, and add to sum then calculating parent index  and add to sum, repeting this until index is 0
    /// running time: O(log(n))
    ///
    /// - parameter index: last index from we calculating sum of original array
    ///
    /// - return: prefix sum from 0 to index
    fileprivate func getSum(index:Int)->Int{
    
        var i = index + 1
        var sum = 0
        while i > 0 {
            sum += fenwickTree![i]
            i = getParent(index: i)
        }
        
        return sum
    }
    
    /**
     * To get parent
     * 1) 2's complement to get minus of index
     * 2) AND this with index
     * 3) Subtract that from index
     */
    fileprivate func getParent(index:Int)->Int{
        return index - (index & -index)
    }
    
    /**
     * To get next
     * 1) 2's complement of get minus of index
     * 2) AND this with index
     * 3) Add it to index
     */
    fileprivate func getNext(index:Int)->Int{
        return index + (index & -index)
    }
    
}
