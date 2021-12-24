//
//  Graph.swift
//  swiftTest
//
//  Created by Tomislav Profico on 18/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

class ConnectingComponentVisitor<T, K>: Visitor<T>{
    
    var data : [K] = []
    
    override func visit(object: T) {
        let s = object as! (currentValue:K, fromValue:K?, fromEdgeWeight:Int?)
        data.append(s.currentValue)
    }
}

class StronglyConnectingComponentVisitor<T : Hashable>: Visitor<T>{
    
    var data : [T] = []
    var explored : [T : Bool] = [:]
    
    override func visit(object: T) {
        data.append(object)
        explored[object] = true
    }
}

class BelmanFordShortestPaths<T: Hashable>{

    fileprivate var map : [T : (distance:Int, parent:T?)]
    
    init(map : [T : (distance:Int, parent:T?)]) {
        self.map = map
    }


    func shortestPath(to endValue: T)->[T]?{
        
        guard map[endValue] != nil else {
            return nil
        }
        
        var result : [T] = []
        
        var end = map[endValue]
        result.append(endValue)
        
        while end!.parent != nil {
            result.append(end!.parent!)
            end = map[end!.parent!]
        }
        
        return result.reversed()
    }
}

class FloydMarshallShortestPaths<T: Comparable & Hashable>{
    
    fileprivate var paths : [[T?]]
    fileprivate var vertexes : [T : Vertex<T>]
    fileprivate var distances:[[Int]]
    
    init(paths:[[T?]],distances:[[Int]], vertexes:[T : Vertex<T>]) {
        self.paths = paths
        self.vertexes = vertexes
        self.distances = distances
    }
    
    func shortestPath(start:T, end:T)->[T]?{
    
        let startVertex = vertexes[start]
        let endVertex = vertexes[end]
        
        guard startVertex != nil && endVertex != nil else {
            return nil
        }
    
        let stack = TPStack<T>()
        stack.push(value: end)
        var newEndIndex = endVertex!.num
        let newStartIndex = startVertex!.num
        var newEnd : T? = end
        while newStartIndex != newEndIndex{
        
            newEnd = paths[newStartIndex][newEndIndex]
            if newEnd == nil{
                return nil
            }
            
            newEndIndex = vertexes[newEnd!]!.num
            
            stack.push(value: newEnd!)
        }
        
        var result : [T] = []
        
        while !stack.isEmpty {
            result.append(stack.pop()!)
        }
        
        return result
    }
    
    func shortestDistance(start:T, end:T)->Int{
        
        let startVertex = vertexes[start]
        let endVertex = vertexes[end]
        
        let newEndIndex = endVertex!.num
        let newStartIndex = startVertex!.num
        
        let distance = distances[newStartIndex][newEndIndex]
        if distance == Int.max{
            return -1
        }
        return distance
    }
    
}

class Vertex<T :Comparable & Hashable> : NSCopying, Hashable, Equatable{

    var name:String
    
    var value : T
    
    fileprivate var tag = Int.max
    
    fileprivate var num = -1
    var edgesFrom : LinkedList<Edge<T>> = LinkedList<Edge<T>>.init { (e1, e2) -> Bool in
        return false
    }
    
    init(name:String = "", value:T) {
        self.name = name
        self.value = value
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Vertex<T>.init(name: name, value: value)
        copy.edgesFrom = edgesFrom
        return copy
    }
    
    var hashValue: Int {
        return value.hashValue
    }
    
    static func == (lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
        return lhs.value == rhs.value
    }
    
}

class Edge<T :Comparable & Hashable>{
    
    var name:String
    
    var weight : Int
    
    weak var startVertex : Vertex<T>?
    weak var endVertex : Vertex<T>?
    
    fileprivate var reversed = false
    
    init(startVertex : Vertex<T>, endVertex: Vertex<T>, name:String = "", weight:Int = 1) {
        self.name = name
        self.weight = weight
        self.startVertex = startVertex
        self.endVertex = endVertex
    }
    
    @discardableResult
    fileprivate func reversedEdge(vertexes : inout[T : Vertex<T>])->Edge<T>{
    
        let newStart = Vertex<T>.init(name: self.endVertex!.name, value: self.endVertex!.value)
        let endStart = Vertex<T>.init(name: self.startVertex!.name, value: self.startVertex!.value)
        
        if vertexes[newStart.value] == nil{
            vertexes[newStart.value] = newStart
        }
        
        if vertexes[endStart.value] == nil{
            vertexes[endStart.value] = endStart
        }
        
        let edge = Edge<T>.init(startVertex: vertexes[newStart.value]!, endVertex: vertexes[endStart.value]!, name: self.name, weight: self.weight)
        vertexes[newStart.value]!.edgesFrom.insertFirst(value: edge)
        return edge
    }
    
}

class Graph<T :Comparable & Hashable> {
    
    fileprivate var vertexes : [T : Vertex<T>] = [:]
    
    fileprivate var edges : LinkedList<Edge<T>> = LinkedList<Edge<T>>.init { (e1, e2) -> Bool in
        return false
    }
    
    fileprivate var isDirected = false
    fileprivate var haveNegativeEdges = false
    
    // MARK:
    // MARK: Build graph
    
    func addVertex(value:T){
        let vertex = Vertex<T>.init(value: value)
        vertex.num = vertexes.count
        vertexes[value] = vertex
        
    }
    
    func addEdge(start:T, destination:T, isDirected:Bool, weight:Int = 1){
        
        if weight < 0{
            haveNegativeEdges = true
        }
        
        if isDirected == true{
            self.isDirected = true
        }
        
        if vertexes[start] == nil{
            addVertex(value: start)
        }
        
        if vertexes[destination] == nil{
            addVertex(value: destination)
        }
        
        let startVertex = vertexes[start]
        let destinationVertex = vertexes[destination]
        let edge = Edge.init(startVertex: startVertex!, endVertex: destinationVertex!, weight: weight)
        startVertex!.edgesFrom.insertFirst(value: edge)
        edges.insertFirst(value: edge)
        
        if isDirected == false{
            let reverseEdge = Edge.init(startVertex: destinationVertex!, endVertex: startVertex!, weight: weight)
            reverseEdge.reversed = true
            destinationVertex!.edgesFrom.insertFirst(value: reverseEdge)
            edges.insertFirst(value: reverseEdge)
        }
    }
    
    func addEdgesFrom(start:T, destinations:[T], isDirected:[Bool], weights:[Int] = [1]){
    
        for i in 0..<destinations.count{
            let dest = destinations[i]
            let direct = isDirected[i]
            let weight = weights.count < i ? weights[i] : 1
            addEdge(start: start, destination: dest, isDirected: direct, weight: weight)
        }
    }
    
    // MARK:
    // MARK: BFS
    
    func breadthFirstSearch(visitor:Visitor<(currentValue:T, fromValue:T?, fromEdgeWeight:Int?)>, fromValue:T){
        
        let startVertex = vertexes[fromValue]
        
        guard startVertex != nil else {
            return
        }
        
        var explored:[T:Bool] = [:]
        
        bfs(visitor: visitor, startVertex: startVertex!, explored: &explored)
    }
    
    func breadthFirstSearch(visitor:Visitor<(currentValue:T, fromValue:T?, fromEdgeWeight:Int?)>){
        
        var explored:[T:Bool] = [:]
        
        for v in vertexes{
            
            if explored[v.key] == true{
                continue
            }
        
            bfs(visitor: visitor, startVertex: v.value, explored: &explored)
        }
    }
    
    fileprivate func bfs(visitor:Visitor<(currentValue:T, fromValue:T?, fromEdgeWeight:Int?)>, startVertex:Vertex<T>, explored: inout[T:Bool]){
    
        let queue = TPQueue<(currentVertex: Vertex<T>,previusVertex: Vertex<T>?, previusEdge: Edge<T>?)>()
        queue.enqueue(value: (startVertex, nil, nil))
        explored[startVertex.value] = true
        while !queue.isEmpty{
            
            let pair = queue.dequeue()!
            visitor.visit(object: (pair.currentVertex.value, pair.previusVertex?.value, pair.previusEdge?.weight))
            let iterator = LinkedListIterator<Edge<T>>.init(list: pair.currentVertex.edgesFrom)
            while iterator.hasNext() == true{
                let edge = iterator.next() as! Edge<T>
                if explored[edge.endVertex!.value] == nil{
                    explored[edge.endVertex!.value] = true
                    queue.enqueue(value: (edge.endVertex!,edge.startVertex!,edge))
                }
            }
        }
    }
    
    // MARK:
    // MARK: DFS
    fileprivate func dfs(visitor:Visitor<T>, startVertex:Vertex<T>, explored: inout[T:Bool]){
        
        let stack = TPStack<Vertex<T>>()
        stack.push(value: startVertex)
        explored[startVertex.value] = true
        while !stack.isEmpty{
            
            let vertex = stack.pop()
            visitor.visit(object: vertex!.value)
            let iterator = LinkedListIterator<Edge<T>>.init(list: vertex!.edgesFrom)
            while iterator.hasNext() == true{
                let edge = iterator.next() as! Edge<T>
                if explored[edge.endVertex!.value] == nil{
                    explored[edge.endVertex!.value] = true
                    stack.push(value: edge.endVertex!)
                }
            }
        }
    }
    
    func depthFirstSearch(visitor:Visitor<T>, fromValue:T){
        
        let startVertex = vertexes[fromValue]
        
        guard startVertex != nil else {
            return
        }
        
        var explored:[T:Bool] = [:]
        
        dfs(visitor: visitor, startVertex: startVertex!, explored: &explored)
    }
    
    func depthFirstSearch(visitor:Visitor<T>){
        
        var explored:[T:Bool] = [:]
        
        for v in vertexes{
            
            if explored[v.key] == true{
                continue
            }
            
            dfs(visitor: visitor, startVertex: v.value, explored: &explored)
        }
    }
    
    // MARK:
    // MARK: All connected components
    
    func allConnectedComponentWithBFS()->[[T]]{
        
        var result : [[T]] = []
        
        var explored:[T:Bool] = [:]
        
        for v in vertexes{
            
            if explored[v.key] == true{
                continue
            }
            
            let visitor = ConnectingComponentVisitor<(currentValue:T, fromValue:T?, fromEdgeWeight:Int?), T>()
            bfs(visitor: visitor, startVertex: v.value, explored: &explored)
            result.append(visitor.data)
        }
        
        return result
    }
    
    // MARK:
    // MARK: Topology sort
    
    func topologySort()->[T]{
    
        var result : [T] = []
        
        var explored : [T : Bool] = [:]
        var stack = TPStack<Vertex<T>>()
        
        for v in vertexes{
            
            if explored[v.key] == true{
                continue
            }
            
            topologySort(explored: &explored, vertex: v.value, stack: &stack)
        }
        
        while !stack.isEmpty {
            let vertex = stack.pop()
            result.append(vertex!.value)
        }
        
        return result
    }
    
    fileprivate func topologySort(explored : inout[T : Bool], vertex:Vertex<T>, stack: inout TPStack<Vertex<T>>){
    
        explored[vertex.value] = true
        
        let iterator = LinkedListIterator<Edge<T>>.init(list: vertex.edgesFrom)
        while iterator.hasNext() == true{
            let edge = iterator.next() as! Edge<T>
            if explored[edge.endVertex!.value] == nil{
                topologySort(explored: &explored, vertex: edge.endVertex!, stack: &stack)
            }
        }
        
        stack.push(value: vertex)
    }
    
    // MARK:
    // MARK: Strongly connected component
    
    func stronglyConnectedComponent() -> [[T]]{
    
        var result : [[T]] = []
        
        var explored : [T : Bool] = [:]
        var stack = TPStack<Vertex<T>>()
        
        for v in vertexes{
            
            if explored[v.key] == true{
                continue
            }
            
            topologySort(explored: &explored, vertex: v.value, stack: &stack)
        }
        
        let reversed = reverseGraph()
        explored = [:]
        let visitor = StronglyConnectingComponentVisitor<T>()
        visitor.explored = explored
        while !stack.isEmpty {
            let vertex = stack.pop()
            
            if explored[vertex!.value] == nil{
                
                reversed.dfs(visitor: visitor, startVertex: reversed.vertexes[vertex!.value]!, explored: &explored)
                result.append(visitor.data)
                visitor.data = []
            }
        }
        return result
    }
    
    fileprivate func reverseGraph()->Graph<T>{
        
        let graph = Graph<T>.init()
        
        for v in self.vertexes{
            if graph.vertexes[v.value.value] == nil{
                graph.addVertex(value: v.value.value)
            }
            let iterator = LinkedListIterator<Edge<T>>.init(list: v.value.edgesFrom)
            while iterator.hasNext() == true{
                let edge = iterator.next() as! Edge<T>
                edge.reversedEdge(vertexes: &graph.vertexes)
            }
        }
        return graph
    }
    
    // MARK:
    // MARK: Dijkstra
    
    func dijsktraShortestPath(startValue:T, endValue:T)->[T]?{
    
        assert(haveNegativeEdges == false, "Dijsktra algoritam can not run on graph with negative edges")
        
        let startVertex = vertexes[startValue]
        
        guard startVertex != nil else {
            return nil
        }
        
        let endVertex = vertexes[endValue]
        
        guard endVertex != nil else {
            return nil
        }
        
        return dijkstra(startVertex: startVertex!, endVertex: endVertex)?[endVertex!.value]
    }
    
    func dijsktraShortestPathToAllVertex(startValue:T)->[T:[T]]?{
        
        assert(haveNegativeEdges == false, "Dijsktra algoritam can not run on graph with negative edges")
        
        let startVertex = vertexes[startValue]
        
        guard startVertex != nil else {
            return nil
        }
        
        return dijkstra(startVertex: startVertex!, endVertex: nil)
        
    }
    
    fileprivate func dijkstra(startVertex:Vertex<T>, endVertex:Vertex<T>?)->[T:[T]]?{
    
        resetVertexesTag()
        
        startVertex.tag = 0
        
        var distanceMap : [T : Int] = [:]
        var pathMap : [T : T?] = [:]
        
        let heap = HeapWithChangableElements<Vertex<T>>.init { (v1, v2) -> Bool in
            v1.tag < v2.tag
        }
        heap.heapify(array: Array(self.vertexes.values))
        
        var current : Vertex<T>?
        
        pathMap[startVertex.value] = nil
        var result : [T:[T]] = [:]
        while !heap.isEmpty() {
            current = heap.extract()
            
            
            if endVertex != nil && current!.value == endVertex!.value{
                return [current!.value : constructPath(pathMap: pathMap, endValue: current!.value)]
            }
            if endVertex == nil{
                result[current!.value] = constructPath(pathMap: pathMap, endValue: current!.value)
                if result[current!.value]?.count == 1{
                    result[current!.value] = nil
                }
            }
            let iterator = LinkedListIterator<Edge<T>>.init(list: current!.edgesFrom)
            while iterator.hasNext() == true{
                let edge = iterator.next() as! Edge<T>
                if heap.contains(value: edge.endVertex!) && current!.tag != Int.max && edge.weight + current!.tag < edge.endVertex!.tag{
                    edge.endVertex!.tag = edge.weight + current!.tag
                    heap.changePriority(newElement: edge.endVertex!, oldElement: edge.endVertex!)
                    pathMap[edge.endVertex!.value] = current!.value
                    distanceMap[edge.endVertex!.value] = current!.tag + edge.weight
                }
            }
        }
    
        return result
    }
    
    fileprivate func constructPath(pathMap:[T : T?], endValue:T)->[T]{
    
        var data : [T] = []
        
        var current = endValue
        
        while pathMap[current] != nil  {
            data.append(current)
            current = pathMap[current]!!
        }
        data.append(current)
        
        return data.reversed()
    }
    
    fileprivate func resetVertexesTag(){
    
        for vertex in vertexes.values{
            vertex.tag = Int.max
        }
    }
    
    // MARK:
    // MARK: Belman Ford
    
    func belmanFordShortestPath(startValue:T)->BelmanFordShortestPaths<T>?{
        
        let startVertex = vertexes[startValue]
        
        guard startVertex != nil else {
            return nil
        }
    
        let map = belmanFord(startVertex: startVertex!)
        
        guard map != nil else {
            return nil
        }
        return BelmanFordShortestPaths<T>.init(map: map!)
    }
    
    fileprivate func belmanFord(startVertex:Vertex<T>)->[T : (distance:Int, parent:T?)]?{
    
        var map : [T : (distance:Int, parent:T?)] = [:]
        
        for vertex in vertexes{
            map[vertex.key] = (Int.max,nil)
        }
        
        map[startVertex.value] = (0, nil)
        var changing = false
        for i in 0...vertexes.count{
            let iterator = LinkedListIterator<Edge<T>>.init(list: edges)
            while iterator.hasNext() == true{
                let edge = iterator.next() as! Edge<T>
                
                let endDistance = map[edge.endVertex!.value]!.distance
                let startDistance = map[edge.startVertex!.value]!.distance
                
                if startDistance != Int.max && endDistance > startDistance + edge.weight{
                    map[edge.endVertex!.value] = (startDistance + edge.weight, edge.startVertex!.value)
                    changing = true
                }
            }
            if changing == false{
                return map
            }else if changing == true && i == vertexes.count{
                return nil;
            }
            changing = false
        }
        
        return map
    }
    
    // MARK:
    // MARK: Floyd Warshall
    
    func floydWarshallAllShortestPathPair()->FloydMarshallShortestPaths<T>?{
    
        var distances = Array.init(repeating: Array.init(repeating: Int.max, count: self.vertexes.count), count: self.vertexes.count)
        var paths : [[T?]] = Array.init(repeating: Array.init(repeating: nil, count: self.vertexes.count), count: self.vertexes.count)
        
        let iterator = LinkedListIterator<Edge<T>>.init(list: edges)
        while iterator.hasNext() == true{
            let edge = iterator.next() as! Edge<T>
        
            if (distances[edge.startVertex!.num][edge.endVertex!.num] > edge.weight){
                distances[edge.startVertex!.num][edge.endVertex!.num] = edge.weight
                paths[edge.startVertex!.num][edge.endVertex!.num] = edge.startVertex!.value
            }
        }
        
        for k in 0..<distances.count{
            for i in 0..<distances.count{
                for j in 0..<distances.count{
                    if distances[i][k] != Int.max && distances[k][j] != Int.max && distances[i][j] > distances[i][k] + distances[k][j]{
                        distances[i][j] = distances[i][k] + distances[k][j]
                        paths[i][j] = paths[k][j]
                    }
                }
            }
        }
        
        for l in 0..<distances.count{
            if(distances[l][l] < 0) {
                return nil
            }
        }
        
        return FloydMarshallShortestPaths<T>.init(paths: paths, distances: distances, vertexes: vertexes)
    }
    
    // MARK:
    // MARK: Minimum spaning tree
    
    func minSpanningTreePrimAlghoritam()->[Edge<T>]?{
    
        guard vertexes.count > 0 else {
            return nil
        }
        
        resetVertexesTag()
    
        let startVertex = Array(vertexes.values).first!
        
        startVertex.tag = 0
        
        
        var pathMap : [T : Edge<T>] = [:]
        var resultEdges : [Edge<T>] = []
        
        let heap = HeapWithChangableElements<Vertex<T>>.init { (v1, v2) -> Bool in
            v1.tag < v2.tag
        }
        heap.heapify(array: Array(self.vertexes.values))
        
        var current : Vertex<T>?
        
        while !heap.isEmpty() {
            current = heap.extract()
            if pathMap[current!.value] != nil{
                resultEdges.append(pathMap[current!.value]!)
            }
            let iterator = LinkedListIterator<Edge<T>>.init(list: current!.edgesFrom)
            while iterator.hasNext() == true{
                let edge = iterator.next() as! Edge<T>
                if heap.contains(value: edge.endVertex!) && edge.weight < (edge.endVertex!.tag) {
                    edge.endVertex!.tag = edge.weight
                    heap.changePriority(newElement: edge.endVertex!, oldElement: edge.endVertex!)
                    pathMap[edge.endVertex!.value] = edge
                }
            }
        }
        
        return resultEdges
    }
    
    func minSpanningTreeKruskalAlghoritam()->[Edge<T>]?{
    
        return kruskal(numberOfClusters: nil, maxWeight: nil).edges
    }
    
    fileprivate func kruskal(numberOfClusters:Int?, maxWeight:Int?)->(edges:[Edge<T>]?,set:DisjoinSets<Vertex<T>>?){
    
        guard vertexes.count > 0 else {
            return (nil,nil)
        }
        
        var edgs : [Edge<T>] = []
        let iterator = LinkedListIterator<Edge<T>>.init(list: edges)
        while iterator.hasNext() == true{
            let edge = iterator.next() as! Edge<T>
            edgs.append(edge)
        }
        
        edgs.sort { (e1, e2) -> Bool in
            e1.weight < e2.weight
        }
        
        var result : [Edge<T>] = []
        let set = DisjoinSets<Vertex<T>>()
        
        set.makeSet(array: Array(vertexes.values))
        
        for edge in edgs{
            let startVertex = edge.startVertex!
            let endVertex = edge.endVertex!
            
            if set.findSet(value: startVertex) !== set.findSet(value: endVertex){
                
                if numberOfClusters != nil && numberOfClusters! == set.numberOfSets{
                    return (result, set)
                }
                if maxWeight != nil && maxWeight! < edge.weight{
                    return (result, set)
                }
                
                set.union(value1: startVertex, value2: endVertex)
                result.append(edge)
                
            }
        }
        
        return (result, set)
    }
    
    
    
    // MARK:
    // MARK: Clustering
    
    func clusteringUsingKruskalAlghoritam(numberOfClusters:Int)->[[Vertex<T>]]?{
    
        if numberOfClusters > vertexes.count{
            return nil
        }
        
        return kruskal(numberOfClusters: numberOfClusters, maxWeight: nil).set!.allSets()
    }
    
    func clusteringUsingKruskalAlghoritam(maxDistance:Int)->[[Vertex<T>]]?{
        
        return kruskal(numberOfClusters: nil, maxWeight: maxDistance).set!.allSets()
    }
    
    // MARK:
    // MARK: Cycle in undirectedGraph
    
    func containCyclesInUndirectedGraph()->Bool{
        
        assert(!self.isDirected,"This graph is directed graph")
    
        let disjoinSet = DisjoinSets<Vertex<T>>()
        disjoinSet.makeSet(array: Array(self.vertexes.values))
        
        let iterator = LinkedListIterator<Edge<T>>.init(list: edges)
        while iterator.hasNext() == true{
            let edge = iterator.next() as! Edge<T>
            
            if edge.reversed{
                continue
            }
        
            let startVertex = edge.startVertex!
            let endVertex = edge.endVertex!
            
            let startSet = disjoinSet.findSet(value: startVertex)
            let endSet = disjoinSet.findSet(value: endVertex)
            
            if startSet != endSet{
                disjoinSet.union(value1: startSet!, value2: endSet!)
            }else{
                return true
            }
        }
        return false
    }
    
   

}
