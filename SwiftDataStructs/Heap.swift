//
//  Heap.swift
//  swiftTest
//
//  Created by Tomislav Profico on 06/12/16.
//  Copyright © 2016 Tomislav Profico. All rights reserved.
//

import UIKit

class Heap<T> {
    
    /// We can consider Heap as tree struct, but we can store element of heap in list, because of tree property that we can easly calculate node children indexes and node parent index, from given index of current node.
    var elements = [T]()
    
    /// We need order function so we can know does heap is MIN-HEAP or MAX-HEAP. Notice that T not need to be inhereted from Comperable, this is because of exist of this order function, so we have control which element is root (MIN or MAX), and which element is extracted first.
    var orderFunction : (T,T)->Bool
    
    
    /// Custom constructor so we can send order function we want
    ///
    /// - parameter orderFunction:  order function
    init(orderFunction:@escaping (T,T)->Bool) {
        self.orderFunction = orderFunction
    }
    
    /// Check if there is any element in heap
    /// running time: O(1)
    ///
    /// - return: is heap empty
    func isEmpty()->Bool{
        return elements.isEmpty
    }
    
    /// Check number of element in heap
    /// running time: O(1)
    ///
    /// - return: number of heap elements
    func count()->Int{
    
        return elements.count
    }
    
    // MARK:
    // MARK: Heapify
    
    /// Init Heap with element of array, this will normaly be done in O(n*log(n)) time by adding each element one by one, but heapify enable do in linear time by adding all elements of array to heap array, and then swaping elements
    /// running time: O(n)
    ///
    /// - parametar array: array which elements need to be swap so we get valid heap tree.
    func heapify(array:[T]){
    
        elements = array
        
        var i = elements.count
        i /= 2
        while i >= 0 {
            heapifyHelper(index: i)
            i -= 1
        }
    }
    
    /// check element children and see if anyone violate orderFunction, and if yes choose (with order function) one children that will be swaped with current element, than swaped this two. When swaped check again if there are more violation.
    ///
    /// - parametar index: index of element that need check his children.
    fileprivate func heapifyHelper(index:Int){
    
        let l = leftChildIndex(index: index)
        let r = rightChildIndex(index: index)
        var largest = 0
        if l < elements.count && orderFunction(elements[l],elements[index]){
            largest = l
        }else{
            largest = index
        }
        
        if r < elements.count && orderFunction(elements[r], elements[largest]){
            largest = r
        }
        
        if largest != index{
        
            swapElementsatIndexes(index1: index, index2: largest)
            heapifyHelper(index: largest)
        }
    }
    
    // MARK:
    // MARK: Insert
    
    /// Insert new element at the end of heap array, and then check up until there is no violation in heap property
    /// running time: O(log(n))
    ///
    /// - parametar value: value that we want insert to heap
    func insert(value:T){
        elements.append(value)
        checkMoveUp(index: elements.count - 1)
    }
    
    // MARK:
    // MARK: extract and search
    
    /// Extract element for heap, If Heap is empty return nil, else take root element in heap, replace it with last elemetnt in array, and starting with new root go down on tree checking (with order function) violation in heap.
    /// running time: O(log(n))
    ///
    /// - return: extracted element (previus root) of heap
    func extract()->T?{
    
        if elements.count <= 0 {
            return nil
        }
        let value = elements[0]
        
        if elements.count <= 1 {
            elements.removeAll()
            return value
        }
        
        let last = elements.removeLast()
        setElement(index: 0, element: last, from: elements.count)
        checkMoveDown(index: 0)
        
        return value
    }
    
    /// Just look at root element in heap
    /// O(1)
    ///
    /// - return: extracted element (root) of heap
    func peek() -> T? {
        return elements.first
    }
    
    // MARK:
    // MARK: check throught tree
    
    
    /// Select element with index, go up through tree, end swap element (respecte orderFunction) until there is no violation in heap tree
    /// running time: O(log(n))
    ///
    /// - parametar index: index of element from which checkUp start
    internal func checkMoveUp(index:Int){
    
        let parent = parentIndex(index: index)
        if parent < 0 || index == 0 {return}
        
        let value = elements[parent]
        
        if !orderFunction(elements[index],value){
            return
        }else{
            swapElementsatIndexes(index1: parent, index2: index)
            checkMoveUp(index: parent)
        }
    }
    
    /// Select element with index, go down through tree, end swap element (respecte orderFunction) until there is no violation in heap tree
    /// running time: O(log(n))
    ///
    /// - parametar index: index of element from which checkDown start
    internal func checkMoveDown(index:Int){
    
        let leftChild = leftChildIndex(index: index)
        let rightChild = rightChildIndex(index: index)
        let childIndex : Int?
        if leftChild >= elements.count && rightChild >= elements.count{
            return
        }else if leftChild >= elements.count{
            childIndex = rightChild
        }else if rightChild >= elements.count{
            childIndex = leftChild
        }else{
            childIndex = orderFunction(elements[leftChild],elements[rightChild]) ? leftChild : rightChild
        }
        
        if orderFunction(elements[index],elements[childIndex!]){
            return
        }else{
            swapElementsatIndexes(index1: index, index2: childIndex!)
            checkMoveDown(index: childIndex!)
        }
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
    
    internal func swapElementsatIndexes(index1:Int, index2:Int){
        let value = elements[index1]
        elements[index1] = elements[index2]
        elements[index2] = value
    }
    
    internal func setElement(index:Int,element:T,from:Int){
    
        elements[index] = element
    }

}


class HeapSort<V>{

    fileprivate var originalHeap: Heap<V>
    var sortedArray :[V]?
    
    init(heap:Heap<V>) {
        originalHeap = heap
        sort()
    }

    fileprivate func sort(){
        sortedArray = []
        while let v = originalHeap.extract(){
            sortedArray!.append(v)
        }
    }
}
