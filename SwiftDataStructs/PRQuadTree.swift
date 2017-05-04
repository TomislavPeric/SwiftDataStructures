//
//  PRQuadTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 24/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

protocol Addable {
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Int) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
}

extension Int: Addable {}
extension Double: Addable {
    internal static func /(lhs: Double, rhs: Int) -> Double {
        return lhs / Double(rhs)
    }
}
extension Float: Addable {
    internal static func /(lhs: Float, rhs: Int) -> Float {
        return lhs / Float(rhs)
    }
}

class QuadNode<X : Comparable, V> {
    
    ///leftTop
    var NE :QuadNode<X , V>?{
        didSet{
            NE?.parent = self
        }
    }
    
    ///leftBottom
    var SE :QuadNode<X , V>?{
        didSet{
            SE?.parent = self
        }
    }
    
    ///rightTop
    var NW :QuadNode<X , V>?{
        didSet{
            NW?.parent = self
        }
    }
    
    ///rightBottom
    var SW :QuadNode<X , V>?{
        didSet{
            SW?.parent = self
        }
    }
    
    weak var parent :QuadNode<X , V>?
    
    var value : V?
    
    var x : X?
    
    var y : X?
    
    init(x:X?, y:X?, value:V?) {
        self.x = x
        self.y = y
        self.value = value
        
    }
    
    func setValues(x:X?, y:X?, value:V?){
        self.x = x
        self.y = y
        self.value = value
    }
    
    func isEmpty()->Bool{
        return x == nil || y == nil
    }
    
    func clear(){
        x = nil
        y = nil
        value = nil
    }
    
    init() {
        
    }
    
    /// is leaf or have children
    func isLeaf()->Bool{
        return NE == nil && SE == nil && NW == nil && SW == nil
    }
    
    func containsAtLeastTwoChild() -> Bool {
        
        var count = 0
        if NW != nil{
            count += 1
        }
        if NE != nil{
            count += 1
        }
        if SE != nil{
            count += 1
        }
        if SW != nil{
            count += 1
        }
        
        return count > 1
        
    }
    
    func margeWithChild(){
        
        guard isLeaf() == false else {
            return
        }
        
        guard containsAtLeastTwoChild() == false else {
            return
        }
        
        if NW != nil{
            setValues(x:NW!.x,y:NW!.y,value:NW!.value)
            NW = nil
        }else if NE != nil{
            setValues(x:NE!.x,y:NE!.y,value:NE!.value)
            NE = nil
        }else if SE != nil{
            setValues(x:SE!.x,y:SE!.y,value:SE!.value)
            SE = nil
        }else if SW != nil{
            setValues(x:SW!.x,y:SW!.y,value:SW!.value)
            SW = nil
        }
        
    }
    
    func removeSelf(){
        
        guard parent != nil else {
            return
        }
        
        if parent!.NW === self{
            parent!.NW = nil
        }else if parent!.NE === self{
            parent!.NE = nil
        }else if parent!.SE === self{
            parent!.SE = nil
        }else if parent!.SW === self{
            parent!.SW = nil
        }
    }
}

class PRQuadTree<X : Comparable & Addable, V> {
    
    /// root node
    fileprivate var root :QuadNode<X, V>?
    
    /// tree bounderies
    fileprivate var minX :X
    fileprivate var minY :X
    fileprivate var maxX :X
    fileprivate var maxY :X
    
    /// constructor, with bounderies parameters
    init(minX:X, minY:X, maxX:X, maxY:X) {
        
        assert(minX < maxX)
        assert(minY < maxY)
        
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
        root = QuadNode<X,V>.init()
    }
    
    /// clear all tree
    func clearTree(){
        root = QuadNode<X,V>.init()
    }
    
    // MARK:
    // MARK: Insert
    
    /// insert point to tree
    /// Average runtime: O(log n) worst O(n)
    ///
    /// - parameter x: x coordinate of point
    /// - parameter y: y coordinate of point
    /// - parameter value: value to insert for point
    func insert(x:X ,y:X, value:V){
        
        guard root != nil else {
            return
        }
        insert(x: x, y: y, value: value, currentNode: root!, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }
    
    /// insert point to tree helper private method. We go recursivley and check in which block currunt coordinate fall.
    ///
    /// - parameter x: x coordinate of point
    /// - parameter y: y coordinate of point
    /// - parameter value: value to insert for point
    /// - parameter value: current node for which we check children
    /// - parameters minX, minY, maxX, maxY : current node bounderies
    fileprivate func insert(x:X ,y:X, value:V, currentNode:QuadNode<X,V>,minX:X, minY:X, maxX:X, maxY:X){
        
        let xDiff = maxX + minX
        let yDiff = maxY + minY
    
        if x >= xDiff / 2 && y >= yDiff / 2{
            insertHelper(x: x, y: y, value: value, currentNode: &currentNode.NE, minX: xDiff / 2, minY: yDiff / 2, maxX: maxX, maxY: maxY)
        }else if x >= xDiff / 2 && y < yDiff / 2{
            insertHelper(x: x, y: y, value: value, currentNode: &currentNode.SE, minX: xDiff / 2, minY: minY, maxX: maxX, maxY: yDiff / 2)
        }else if x < xDiff / 2 && y < yDiff / 2{
            insertHelper(x: x, y: y, value: value, currentNode: &currentNode.SW, minX: minX, minY: minY, maxX: xDiff / 2, maxY: yDiff / 2)
        }else if x < xDiff / 2 && y >= yDiff / 2{
            insertHelper(x: x, y: y, value: value, currentNode: &currentNode.NW, minX: minX, minY: yDiff / 2, maxX: xDiff / 2, maxY: maxY)
        }
    }
    
    /// insert point to tree helper private method. We check if current node is nil if yes than we need insert in it current point and her value. If is not nil  we check if this node is leaf, if yes we check if we inserted duplicate point if yes update this point with new value and return else we remove this value from this node and add both past point of node and new inserted point as node children. If current node is not leaf just continue go down in tree recursivly.
    ///
    /// - parameter x: x coordinate of point
    /// - parameter y: y coordinate of point
    /// - parameter value: value to insert for point
    /// - parameter value: current node for which we check children
    /// - parameters minX, minY, maxX, maxY : current node bounderies
    fileprivate func insertHelper(x:X ,y:X, value:V, currentNode: inout QuadNode<X,V>?,minX:X, minY:X, maxX:X, maxY:X){
        if currentNode == nil{
            currentNode = QuadNode<X,V>.init(x: x, y: y, value: value)
        }else{
            if !currentNode!.isEmpty(){
                if currentNode!.x == x && currentNode!.y == y{
                    currentNode!.value = value
                    return
                }
                let res = removeNodeAndGoDown(node: currentNode!)
                insert(x: res.x, y: res.y, value: res.value, currentNode: currentNode!, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
            }
            insert(x: x, y: y, value: value, currentNode: currentNode!, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        }
    }
    
    /// remove point from node and return its coordinate and value so we can insert this point in node children
    ///
    /// - parameter node: node which is value removed
    ///
    /// - return: returning tupples with coordinate and value of removed point so we can isert this point down in tree
    fileprivate func removeNodeAndGoDown(node:QuadNode<X,V>) -> (x: X, y: X, value:V){
    
        let x = node.x
        let y = node.y
        let value = node.value
        node.clear()
        
        return (x!, y!, value!)
    }
    
    // MARK:
    // MARK: Search
    
    /// Search if point exist and if yes return her value.
    ///
    /// - parameter x: x coordinate of point
    /// - parameter y: y coordinate of point
    ///
    /// - return: value of search point if exist
    func serach(x:X, y:X)->V?{
        
        guard root != nil else {
            return nil
        }
        return search(x: x, y: y, currentNode: &root, minX: minX, minY: minY, maxX: maxX, maxY: maxY)?.value
    }
    
    /// Search if point exist and if yes return assoisiate node. We going recursivly searching bouderies in which this point would fall. If current node is nil the point not exist and return nil else if current node is leaf and its cooridnate if equel to search coordinate then we return tcurrent node, else go down tree searching for point
    ///
    /// - parameter x: x coordinate of point
    /// - parameter y: y coordinate of point
    /// - parameter currentNode: current node in which point fall
    /// - parameters minX, minY, maxX, maxY : current node bounderies
    ///
    /// - return: node of search point if exist
    fileprivate func search(x:X, y:X, currentNode: inout QuadNode<X,V>?,minX:X, minY:X, maxX:X, maxY:X)->QuadNode<X,V>?{
        
        if currentNode == nil{
            
            return nil
        }else if !currentNode!.isEmpty() && currentNode!.x == x && currentNode!.y == y{
            
            return currentNode
        }else if !currentNode!.isEmpty(){
            
            return nil
        }
    
        let xDiff = maxX + minX
        let yDiff = maxY + minY
        
        if x >= xDiff / 2 && y >= yDiff / 2{
            return search(x: x, y: y, currentNode: &currentNode!.NE, minX: xDiff / 2, minY: yDiff / 2, maxX: maxX, maxY: maxY)
        }else if x >= xDiff / 2 && y < yDiff / 2{
            return search(x: x, y: y, currentNode: &currentNode!.SE, minX: xDiff / 2, minY: minY, maxX: maxX, maxY: yDiff / 2)
        }else if x < xDiff / 2 && y < yDiff / 2{
            return search(x: x, y: y, currentNode: &currentNode!.SW, minX: minX, minY: minY, maxX: xDiff / 2, maxY: yDiff / 2)
        }else if x < xDiff / 2 && y >= yDiff / 2{
            return search(x: x, y: y, currentNode: &currentNode!.NW, minX: minX, minY: yDiff / 2, maxX: xDiff / 2, maxY: maxY)
        }
        
        return nil
    }
    
    /// Search all point in range
    ///
    /// - parameters minX, minY, maxX, maxY : search bounderies
    ///
    /// - return: all points data in some rect
    func searchRange(minX: X, minY: X, maxX: X, maxY: X) -> [(x: X, y: X, value:V)]?{
        
        guard root != nil else {
            return nil
        }
        
        assert(minX <= maxX)
        assert(minY <= maxY)
        
        var data : [(x: X, y: X, value:V)]? = []
    
        searchRange(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: root, currentMinX: self.minX, currentMinY: self.minY, currentMaxX: self.maxX, currentMaxY: self.maxY, data:&data, updateValue:nil)
        return data
    }
    
    /// Search all point in range helper private method. check if current node is full inside search range if yes add all points from this node and  its children nodes to data, else if ther is no any overaping finish procedure for this node, else ther is some intersation, if node is leaf check if his point is inside range and if yes add it to data else check all of its child
    ///
    /// - parameters minX, minY, maxX, maxY : search bounderies
    /// - parameter currentNode: current node which we check if it and his children have point inside range
    /// - parameters currentMinX, currentMinY, currentMaxX, currentMaxY : current node bounderies
    /// - parameter data: found points
    /// - parameter updateValue: if we want update all points with some methode pass some not nil value else pass nil
    fileprivate func searchRange(minX: X, minY: X, maxX:X, maxY: X, currentNode: QuadNode<X, V>?, currentMinX: X, currentMinY: X, currentMaxX: X, currentMaxY: X, data: inout[(x: X, y: X, value:V)]?, updateValue:V?){
        
        guard currentNode != nil else {
            return
        }
        
        if minX  <= currentMinX && maxX >= currentMaxX && minY <= currentMinY && maxY >= currentMaxY{
            // full intersect
            addAllPointsToData(data: &data, currentNode: currentNode)
        }else if (minX > currentMaxX || currentMinX > maxX) || (minY > currentMaxY || currentMinY > maxY) {
        // no overlaping
        }else{
            if currentNode!.isLeaf(){
                if currentNode!.x! >= minX && currentNode!.x! <= maxX && currentNode!.y! >= minY && currentNode!.y! <= maxY{
                    if updateValue != nil{
                        currentNode!.value = updateValue
                    }
                    data!.append((currentNode!.x!,currentNode!.y!,currentNode!.value!))
                }
            }else{
                
                let xDiff = currentMaxX + currentMinX
                let yDiff = currentMaxY + currentMinY
                
                searchRange(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NW, currentMinX: currentMinX, currentMinY: yDiff / 2, currentMaxX: xDiff / 2, currentMaxY: currentMaxY, data: &data, updateValue:updateValue)
                searchRange(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NE, currentMinX: xDiff / 2, currentMinY: yDiff / 2, currentMaxX: currentMaxX, currentMaxY: currentMaxY, data: &data, updateValue:updateValue)
                searchRange(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SW, currentMinX: currentMinX, currentMinY: currentMinY, currentMaxX: xDiff / 2, currentMaxY: yDiff / 2, data: &data, updateValue:updateValue)
                searchRange(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SE, currentMinX: xDiff / 2, currentMinY: currentMinY, currentMaxX: currentMaxX, currentMaxY: yDiff / 2, data: &data, updateValue:updateValue)
            }
        }
    }
    
    /// node if full inside searched range and add all points inside this node to data
    ///
    /// - parameter data: found points
    /// - parameter currentNode: current node which points are add
    fileprivate func addAllPointsToData(data: inout[(x: X, y: X, value:V)]?, currentNode:QuadNode<X,V>?){
        
        if currentNode == nil{
            return
        }
        if !currentNode!.isEmpty(){
            data?.append((currentNode!.x!, currentNode!.y!, currentNode!.value!))
            return
        }
        
        addAllPointsToData(data: &data, currentNode: currentNode!.NE)
        addAllPointsToData(data: &data, currentNode: currentNode!.NW)
        addAllPointsToData(data: &data, currentNode: currentNode!.SE)
        addAllPointsToData(data: &data, currentNode: currentNode!.SW)
    }
    
    /// Search all point in circle. Construct rect from cirlcle get all points inside rect, check every point is in circle
    ///
    /// - parameter radius : cirlcle radius
    /// - parameter centerX : x coordinate of circle center
    /// - parameter centerY : y coordinate of circle center
    ///
    /// - return: all points data in some circle
    func searchRadius(radius:X, centerX:X, centerY:X) -> [(x: X, y: X, value:V)]?{
    
        let l = searchRange(minX: centerX - radius, minY: centerY - radius, maxX: centerX + radius, maxY: centerY + radius)
        
        guard l != nil else {
            return nil
        }
        var data : [(x: X, y: X, value:V)]? = []
        for point in l!{
            
            let xCalc = (point.x - centerX) * (point.x - centerX)
            let yCalc = (point.y - centerY) * (point.y - centerY)
            
            if (xCalc + yCalc) <= (radius * radius){
                data!.append(point)
            }
        }
        
        return data
    }
    
    // MARK:
    // MARK: Delete
    
    /// Delete if point exist. First search for not if node not exist return, else remove this node take his previus perent and check if we can delete this parent
    ///
    /// - parameter x: x coordinate of point
    /// - parameter y: y coordinate of point
    func delete(x:X,y:X){
        
        guard root != nil else {
            return
        }
        
        let node = search(x: x, y: y, currentNode: &root, minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        
        guard node != nil else{
            return
        }
        
        let parent = node!.parent
        node!.removeSelf()
        checkDeletion(node: parent)
    }
    
    /// Check if node can be deleter if node is nil return. else if node is leaf remove him and go recursivly with his parent, if it have one or zero child marg this parent with his child and go up checking, else finish proces.
    ///
    /// - parameter node: node to check
    fileprivate func checkDeletion(node:QuadNode<X,V>?){
        
        guard node != nil else {
            return
        }
        
        if node!.isLeaf(){
            let parent = node!.parent
            node!.removeSelf()
            checkDeletion(node: parent)
        }else if !node!.containsAtLeastTwoChild(){
            let parent = node!.parent
            node!.margeWithChild()
            checkDeletion(node: parent)
        }
    }
    
    // MARK:
    // MARK: Update
    
    /// Update rectangle with some new value.
    ///
    /// - parameter minX: X, minY: X, maxX: X, maxY: X: bounderis of rect
    /// - parameter value: value with which all value are updated
    ///
    /// - return: tupple with array of all points that is updated
    func updateRange(minX: X, minY: X, maxX: X, maxY: X, withValue value:V)-> [(x: X, y: X, value:V)]?{
        
        guard root != nil else {
            return nil
        }
        var data : [(x: X, y: X, value:V)]? = []
        searchRange(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: root, currentMinX: self.minX, currentMinY: self.minY, currentMaxX: self.maxX, currentMaxY: self.maxY, data: &data, updateValue: value)
        return data
    }
    
    // MARK:
    // MARK: Find nearest neighboor
    
    /// Find nearist neighboor of point if exist. THis method get all posibilities point to check. and than find nearist of this point.
    ///
    /// - parameter x: x coordinate of search point
    /// - parameter y: y coordinate of search point
    ///
    /// - return: tupple with near neighboor data if exist
    func neighboor(x: X, y: X)->(x: X, y: X, value:V)?{
        
        guard root != nil else {
            return nil
        }
        
        let posibilities = searchAllNeigboorsNode(x: x, y: y, currentNode: root!, minX: self.minX, minY: self.minY, maxX: self.maxX, maxY: self.maxY)
        
        guard posibilities != nil else {
            return nil
        }
        var minSquer : X?
        var minNode : QuadNode<X,V>?
        for currentNode in posibilities!{
        
            let dSquer = (currentNode.x! - x) * (currentNode.x! - x) + (currentNode.y! - y) * (currentNode.y! - y)
            
            if minSquer == nil || minSquer! > dSquer{
                minSquer = dSquer
                minNode = currentNode
            }
        
        }
        guard minNode != nil else {
            return nil
        }
        
        return (minNode!.x!, minNode!.y!, minNode!.value!)
    
    }
    
    /// Find bounderies in which will searched point fall. When found call searchForNeigbors method, and return all poisiblities for neighboor node
    ///
    /// - parameter x: x coordinate of search point
    /// - parameter y: y coordinate of search point
    /// - parameter minX: X, minY: X, maxX: X, maxY: X: bounderis of current node
    /// - parameter currentNode: currentNode for we check if point fall
    ///
    /// - return: all poisiblities for neighboor node
    fileprivate func searchAllNeigboorsNode(x:X, y:X, currentNode: QuadNode<X,V>?,minX:X, minY:X, maxX:X, maxY:X)->[QuadNode<X,V>]?{
        
        if currentNode == nil{
            var data:[QuadNode<X,V>] = []
            searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: root!, currentMinX: self.minX, currentMinY: self.minY, currentMaxX: self.maxX, currentMaxY: self.maxY, data: &data)
            return data
        }else if currentNode === root && !currentNode!.isEmpty(){
            return [root!]
        }
        if !currentNode!.isEmpty() && currentNode!.x == x && currentNode!.y == y{
            return [currentNode!]
        }else if !currentNode!.isEmpty(){
            var data = [currentNode!]
            searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: root!, currentMinX: self.minX, currentMinY: self.minY, currentMaxX: self.maxX, currentMaxY: self.maxY, data: &data)
            /*let dSquer = (currentNode!.x! - x) * (currentNode!.x! - x) + (currentNode!.y! - y) * (currentNode!.y! - y)*/
            return data
        }
        
        let xDiff = maxX + minX
        let yDiff = maxY + minY
        
        if x >= xDiff / 2 && y >= yDiff / 2{
            return searchAllNeigboorsNode(x: x, y: y, currentNode: currentNode!.NE, minX: xDiff / 2, minY: yDiff / 2, maxX: maxX, maxY: maxY)
        }else if x >= xDiff / 2 && y < yDiff / 2{
            return searchAllNeigboorsNode(x: x, y: y, currentNode: currentNode!.SE, minX: xDiff / 2, minY: minY, maxX: maxX, maxY: yDiff / 2)
        }else if x < xDiff / 2 && y < yDiff / 2{
            return searchAllNeigboorsNode(x: x, y: y, currentNode: currentNode!.SW, minX: minX, minY: minY, maxX: xDiff / 2, maxY: yDiff / 2)
        }else if x < xDiff / 2 && y >= yDiff / 2{
            return searchAllNeigboorsNode(x: x, y: y, currentNode: currentNode!.NW, minX: minX, minY: yDiff / 2, maxX: xDiff / 2, maxY: maxY)
        }
        
        return nil
    }
    
    /// Serach all neighboor node of given node. If current bounderies is full inside search bounderies call this function recursivly for each child. If not any overlaping end process for this node, if some overlaping, check if current bounderies is side or corner neigboor, if no continue else check if node is leaf if yes add node to data else recursivly call with new poisible neigboors (is corner neigboor only one child else two child is possible neighboor)
    ///
    /// - parameter data: found neigboors
    /// - parameter minX: X, minY: X, maxX: X, maxY: X: given node bounderies
    /// - parameter currentNode: currentNode for we check if is neighboor
    /// - parameters currentMinX, currentMinY, currentMaxX, currentMaxY : current node bounderies
    ///
    /// - return: all poisiblities for neighboor node
    fileprivate func searchForNeigbors(minX:X, minY:X, maxX:X, maxY:X, currentNode: QuadNode<X, V>?, currentMinX: X, currentMinY: X, currentMaxX: X, currentMaxY: X, data: inout [QuadNode<X,V>]){
        
        guard currentNode != nil else {
            return
        }
        let xDiff = currentMaxX + currentMinX
        let yDiff = currentMaxY + currentMinY
        
        if currentMinX <= minX && currentMaxX >= maxX && currentMinY <= minY && currentMaxY >= maxY{
            
            searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NW, currentMinX: currentMinX, currentMinY: yDiff / 2, currentMaxX: xDiff / 2, currentMaxY: currentMaxY, data: &data)
            searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NE, currentMinX: xDiff / 2, currentMinY: yDiff / 2, currentMaxX: currentMaxX, currentMaxY: currentMaxY, data: &data)
            searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SW, currentMinX: currentMinX, currentMinY: currentMinY, currentMaxX: xDiff / 2, currentMaxY: yDiff / 2, data: &data)
            searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SE, currentMinX: xDiff / 2, currentMinY: currentMinY, currentMaxX: currentMaxX, currentMaxY: yDiff / 2, data: &data)
            
        }else if (minX > currentMaxX || currentMinX > maxX) || (minY > currentMaxY || currentMinY > maxY) {
            // no overlaping
        }else{
            if currentMaxX == minX && currentMinY == maxY{
                // top left corner
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SW, currentMinX: currentMinX, currentMinY: currentMinY, currentMaxX: xDiff / 2, currentMaxY: yDiff / 2, data: &data)
                }
            }else if currentMaxX == minX && currentMaxY == minY{
                // bottum left corner
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NW, currentMinX: currentMinX, currentMinY: yDiff / 2, currentMaxX: xDiff / 2, currentMaxY: currentMaxY, data: &data)
                }
            
            }else if currentMinX == maxX && currentMinY == maxY{
                // top right corner
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SE, currentMinX: xDiff / 2, currentMinY: currentMinY, currentMaxX: currentMaxX, currentMaxY: yDiff / 2, data: &data)
                }
                
            }else if currentMinX == maxX && currentMaxY == minY{
                // bottum right corner
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NE, currentMinX: xDiff / 2, currentMinY: yDiff / 2, currentMaxX: currentMaxX, currentMaxY: currentMaxY, data: &data)
                }
            }else if currentMinY == maxY{
                //top side
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SW, currentMinX: currentMinX, currentMinY: currentMinY, currentMaxX: xDiff / 2, currentMaxY: yDiff / 2, data: &data)
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SE, currentMinX: xDiff / 2, currentMinY: currentMinY, currentMaxX: currentMaxX, currentMaxY: yDiff / 2, data: &data)
                }
            }else if currentMaxY == minY{
                //bottum side
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NW, currentMinX: currentMinX, currentMinY: yDiff / 2, currentMaxX: xDiff / 2, currentMaxY: currentMaxY, data: &data)
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NE, currentMinX: xDiff / 2, currentMinY: yDiff / 2, currentMaxX: currentMaxX, currentMaxY: currentMaxY, data: &data)
                }
            }else if currentMaxX == minX{
                //left side
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NE, currentMinX: xDiff / 2, currentMinY: yDiff / 2, currentMaxX: currentMaxX, currentMaxY: currentMaxY, data: &data)
                    searchForNeigbors(minX:minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SE, currentMinX: xDiff / 2, currentMinY: currentMinY, currentMaxX: currentMaxX, currentMaxY: yDiff / 2, data: &data)
                }
            }else if currentMinX == maxX{
                //right side
                if currentNode!.isLeaf(){
                    data.append(currentNode!)
                }else{
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.NW, currentMinX: currentMinX, currentMinY: yDiff / 2, currentMaxX: xDiff / 2, currentMaxY: currentMaxY, data: &data)
                    searchForNeigbors(minX: minX, minY: minY, maxX: maxX, maxY: maxY, currentNode: currentNode!.SW, currentMinX: currentMinX, currentMinY: currentMinY, currentMaxX: xDiff / 2, currentMaxY: yDiff / 2, data: &data)
                }
            }
        }
    }
}
