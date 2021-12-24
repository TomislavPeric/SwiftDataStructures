//
//  RedixTree.swift
//  swiftTest
//
//  Created by Tomislav Profico on 06/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.
//

import UIKit

// we can use Trie node for this data structure, just need add few new propertys like list of edges and current Value on node
internal extension TrieNode {

    /// add edge to tree
    ///
    /// - parameter key: key for which is added edge
    /// - parameter v: new edge that connect this node with his child
    func inserEdge(edge:RadixEdge,key:Character){
    
        if edges == nil{
            edges = [:]
        }
        edges![key] = edge
    }
    
    /// remove edge from tree
    ///
    /// - parameter key: key for which is edge removed
    func removeEdge(key:Character){
    
        if edges == nil{
            edges = [:]
        }
        edges![key] = nil
    }
}

// Edge, connect two nodes, and have value that is equel to first charchter of child node, this is need so we can efficiently search if some prefix exist in tree
class RadixEdge{

    var value:Character
    var startNode: TrieNode<String>
    var endNode: TrieNode<String>
    
    init(value:Character, startNode:TrieNode<String>,endNode:TrieNode<String>) {
        self.value = value
        self.startNode = startNode
        self.endNode = endNode
        startNode.inserEdge(edge: self, key: value)
    }
    
}

// Similar to Trie just space efficent

class RadixTree {
    
    // root of tree at start empty
    fileprivate var root : TrieNode<String>
    
    init() {
        root = TrieNode<String>()
    }
    
    // MARK:
    // MARK: Insert
    
    /// insert string in tree, we check is string is empty and then recursively insert string
    /// running time: if n is number of charachter in string then O(n)
    ///
    /// - parameter word: string added to tree
    func insert(word:String){
        
        assert(!word.isEmpty, "Inserted word can not be nil")
        
        insertHelper(word: word.lowercased(), node: root)
    }

    /// helper method which insert word in tree. There is few cases if current node (in start root) do not contain any edge with key equel to first charachter in string, then insert new node as chil of current node with key equel string need to be inserted. Else we need compere inserted string and value string in end node of found edge, after this we get result with common prefix of two, and both suffix of new string we want insert and string at node. If both suffix are empty that mean that string and value in node are same and we need just set isEnded property of node to be true. Else if result has only suffix of new string than we recursively continue this procedure but now string is suffix of new node and node is end node of found edge. Else if suffix of string in node is only exist, then we just need insert new node with inserted string in front of old node, which now change value to his old suffix. Else if both suffix exist we insert common prefix in front of current node, which value is now is equel to his suffix, and then we recursively continue procedure with string equel to new word suffix.
    ///
    /// - parameter word: string added to tree
    /// - parameter node: current node
    fileprivate func insertHelper(word:String,node:TrieNode<String>){
    
        let firstCharachter = word.first!
        if let edge = node.edges?[firstCharachter]{
            let compareResults = compareTwoStrings(stringToAdd: word, stringAtNode: edge.endNode.value!)
            if compareResults.lastFromNewNode.isEmpty == true && compareResults.lastFromOldNode.isEmpty == true{
                edge.endNode.isEnded = true
                return
            }else if  compareResults.lastFromNewNode.isEmpty == true{
                _ = insertNewNode(string: compareResults.commonPrefix, firstCharachter: firstCharachter, beforeNode: edge.endNode,suffix: compareResults.lastFromOldNode,isEndedFirst: false)
            }else if  compareResults.lastFromOldNode.isEmpty == true{
                insertHelper(word: compareResults.lastFromNewNode, node: edge.endNode)
            }else{
                let newNode = insertNewNode(string: compareResults.commonPrefix, firstCharachter: firstCharachter, beforeNode: edge.endNode,suffix: compareResults.lastFromOldNode,isEndedFirst: true)
                insertHelper(word: compareResults.lastFromNewNode, node: newNode)
            }
        }else{
            addNewNode(string: word, firstCharachter: firstCharachter, node: node)
        }
    }
    
    /// simply add new node in tree as child of parameter node
    ///
    /// - parameter string: string added to tree
    /// - parameter firstCharachter: firstCharachter of string added to tree
    /// - parameter node: parent node of new node
    fileprivate func addNewNode(string:String,firstCharachter:Character,node:TrieNode<String>){
    
        let nodeToAdd = TrieNode<String>.init(isEnded: true)
        nodeToAdd.value = string
        node.addChildren(c: string, node: nodeToAdd)
        _ = RadixEdge.init(value: firstCharachter, startNode: node, endNode: nodeToAdd)
    }
    
    /// insert new node in front of beforeNode in parameter
    ///
    /// - parameter string: string added to tree
    /// - parameter firstCharachter: firstCharachter of string added to tree
    /// - parameter beforeNode: child node of new node
    /// - parameter suffix: beforeNode new value
    /// - parameter isEndedFirst: check if beforeNode isEnded property is now false
    ///
    /// - return: inserted node
    fileprivate func insertNewNode(string:String,firstCharachter:Character,beforeNode:TrieNode<String>, suffix:String, isEndedFirst:Bool)->TrieNode<String>{
        
        
        let nodeToAdd = TrieNode<String>.init(isEnded: true)
        if (isEndedFirst){
            nodeToAdd.isEnded = false
        }
        let parent = beforeNode.parent
        parent?.addChildren(c: string, node: nodeToAdd)
        parent?.removeChild(key: beforeNode.value!)
        parent?.removeEdge(key: firstCharachter)
        nodeToAdd.value = string
        nodeToAdd.addChildren(c: suffix, node: beforeNode)
        beforeNode.value = suffix
        if parent != nil {_ = RadixEdge.init(value: firstCharachter, startNode: parent!, endNode: nodeToAdd)}
        _ = RadixEdge.init(value: suffix.first!, startNode: nodeToAdd, endNode: beforeNode)
        return nodeToAdd
    }
    
    /// compere two strings, and return tupple with informtion about commonPrefix and both string suffix
    ///
    /// - parameter stringToAdd: string to compare
    /// - parameter stringAtNode: string to compare
    ///
    /// - return: with informtion about commonPrefix and both string suffix
    fileprivate func compareTwoStrings(stringToAdd:String,stringAtNode:String)->(commonPrefix: String, lastFromOldNode: String,lastFromNewNode: String, isInsertedBefore:Bool){
        
        let isNodeStringLarger = stringAtNode.count > stringToAdd.count
        
        let commonPrefix = stringAtNode.commonPrefix(with: stringToAdd)
        
        let maxi = max(stringAtNode.count, stringToAdd.count)
        let diff = max(maxi - commonPrefix.count,0)
        
        let mini = min(stringAtNode.count, stringToAdd.count)
        let miniDiff = max(mini - commonPrefix.count,0)
        
        let a = isNodeStringLarger ? stringAtNode : stringToAdd
        let b = isNodeStringLarger ? stringToAdd : stringAtNode
        
        let lastFromOldNode = isNodeStringLarger ? String(a[a.index(a.endIndex, offsetBy: -diff)...]) : String(b[b.index(b.endIndex, offsetBy: -miniDiff)...])
        let lastFromNewNode = isNodeStringLarger ? String(b[b.index(b.endIndex, offsetBy: -miniDiff)...]) : String(a[a.index(a.endIndex, offsetBy: -diff)...])
        return (commonPrefix,lastFromOldNode,lastFromNewNode,isNodeStringLarger)
        
    }
    
    // MARK:
    // MARK: search
    
    /// check if string exist in tree
    ///
    /// - string stringToAdd: string to check
    ///
    /// - return: is string exist in tree
    func searchString(string:String)->Bool{
        
        guard !string.isEmpty else {
            return false
        }
        
        let node = nodeOfSearchString(string:string.lowercased(), searchingForPrefix:  false, node: root)
    
        if node == nil || node!.isEnded == false{
            return false;
        }
        return true
    }
    
    /// check if prefix exist in tree
    ///
    /// - string prefix: prefix to check
    ///
    /// - return: is prefix exist in tree
    func searchPrefix(prefix:String)->Bool{
        
        guard !prefix.isEmpty else {
            return false
        }
        
        let node = nodeOfSearchString(string:prefix.lowercased(), searchingForPrefix:  true, node: root)
    
        return node != nil
    }
    
    /// return all string for given prefix if exist else return nil. Also check if prefix is empty.
    ///
    /// - string prefix: prefix to check
    ///
    /// - return: array of all string for prefix, if there is no prefix return nil
    func allStringForPrefix(prefix:String)->[String]?{
        
        guard !prefix.isEmpty else {
            return nil
        }
    
        let node = nodeOfSearchString(string:prefix.lowercased(), searchingForPrefix:  true, node: root)
        
        if node == nil{
            return nil
        }
    
        let currentPrefix = nodePrefix(node: node!)
        
        var data = [String]()
        allNodeStrings(node: node!, prefix: currentPrefix, data: &data)
        return data
        
    }
    
    /// Private helper method helping finding all string for prefix recursively. For some node check if node is end of word, and if yes add current prefix in data array, than  recursively check each child of that node, and if there are end of word.
    ///
    /// - parameter node: node we check does he end of word
    /// - parameter prefix: current prefix, prefix until this node
    /// - parameter data: array of word we found for some prefix
    fileprivate func allNodeStrings(node:TrieNode<String>,prefix:String, data:inout [String]){
        
        if node.isEnded == true{
            data.append(prefix.lowercased())
        }
        
        for key in node.childrens.keys{
            let newPrefix = prefix + String(key)
            let child = node.childrens[key]
            allNodeStrings(node: child!, prefix: newPrefix, data: &data)
        }
    }
    
    /// Search prefix for node. Go up taking node parent and constructing prefix
    ///
    /// - parameter node: node we check
    ///
    /// - return: prefix until node
    fileprivate func nodePrefix(node:TrieNode<String>)->String{
    
        var prefix = ""
        var currentNode = node
        if currentNode === root{
        
            return prefix
        }
        
        while currentNode !== root {
            prefix = currentNode.value! + prefix
            currentNode = currentNode.parent!
        }
        
        return prefix
    }
    
    /// Search node for prefix or full word
    ///
    /// - parameter string: string we check
    /// - parameter searchingForPrefix: does we searching for prefix or full node
    ///
    /// - return: found node
    fileprivate func nodeOfSearchString(string:String, searchingForPrefix:Bool,node:TrieNode<String>)->TrieNode<String>?{
        
        var currentNode = node
        let charachter = string.first!
        let edge = currentNode.edges?[charachter]
        
        if edge == nil{
            return nil
        }else{
            currentNode = edge!.endNode
            if currentNode.value == string && (currentNode.isEnded || searchingForPrefix){
                return currentNode
            }else if currentNode.value == string && !currentNode.isEnded && !searchingForPrefix{
                return nil
            }else if currentNode.value!.count > string.count{
                if (!searchingForPrefix){
                    return nil
                }
                return currentNode.parent!
            }else{
                let commonPrefix = currentNode.value!.commonPrefix(with: string)
                let index = commonPrefix.index(commonPrefix.endIndex, offsetBy: 0)
                let newSearchedString = String(string[index...])
                return nodeOfSearchString(string: newSearchedString, searchingForPrefix: searchingForPrefix,node:edge!.endNode)
            }
        }
    }
    
    // MARK:
    // MARK: Delete
    
    /// Remove string from tree. First search if node with string exist if no return else, set it isEnded property to false, if node have not any child just remove it, else if if is only child of his parent and parrent is not root then connect this two
    ///
    /// - parameter string: string we delete
    func removeString(string:String){
        
        guard !string.isEmpty else {
            return
        }
    
        let node = nodeOfSearchString(string: string, searchingForPrefix: false, node: root)
        if node == nil{
            return
        }
        node!.isEnded = false
        if node!.childrens.count == 0{
            node!.parent?.removeChild(key: node!.value!)
            if node!.parent !== root && node!.parent!.childrens.count == 1 && (!node!.parent!.childrens.first!.value.isEnded || !node!.parent!.isEnded){
                connectWithParentNode(node: node!.parent!.childrens.first!.value)
            }
        }else if node!.parent !== root &&  node!.parent!.childrens.count == 1{
            connectWithParentNode(node: node!)
        }else if node!.childrens.count == 1{
            connectWithParentNode(node: node!.childrens.first!.value)
        }
    
    }
    
    /// Connect node with his parent. (parent node must have only one child)
    ///
    /// - parameter node: node we want connect with its parent
    fileprivate func connectWithParentNode(node:TrieNode<String>){
    
        guard node !== root && node.parent !== root else{
            return
        }
        
        let parent = node.parent!
        let newValue = parent.value! + node.value!
        parent.setChildrens(childrens:node.childrens)
        parent.parent!.removeChild(key: parent.value!)
        parent.parent!.addChildren(c: newValue, node: parent)
        parent.value = newValue
        parent.isEnded = true
    }
   
}
