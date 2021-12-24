//
//  Trie.swift
//  swiftTest
//
//  Created by Tomislav Profico on 06/02/17.
//  Copyright © 2017 Tomislav Profico. All rights reserved.

import UIKit

class TrieNode<K: Hashable>{
    
    // bool value say us does any word finish here
    var isEnded : Bool
    
    // read-only property, all childrens of node are store here, keys are charahter, and value is next node.
    public private(set) var childrens : [K:TrieNode<K>]
    
    // parent of node and his charachter for which this node is children (where useful for delete method)
    weak var parent : TrieNode?
    var parentCharachter : K?
    
    var edges: [Character:RadixEdge]?
    var value: String?
    
    convenience init() {
        self.init(isEnded:false)
    }
    
    init(isEnded:Bool) {
        self.isEnded = isEnded
        childrens = [:]
    }
    
    /// add child to tree, and in same time setup his parent
    ///
    /// - parameter c: key for which is adden children node
    /// - parameter node: new node added as child
    func addChildren(c:K,node:TrieNode){
        childrens[c] = node
        node.parent = self
        node.parentCharachter = c
    }
    
    /// remove child from tree
    ///
    /// - parameter key: key which we remove
    func removeChild(key:K){
        childrens.removeValue(forKey: key)
    }
    
    func setChildrens(childrens: [K:TrieNode<K>]){
        self.childrens = childrens
    }
}

class Trie {
    
    // root of tree at start empty
    private var root : TrieNode<Character> = TrieNode()
    
    /*init() {
        root = TrieNode()
    }*/
    
    // MARK:
    // MARK: Insert
    
    /// insert string in tree, we go charachter by charachter and check if prefix exist if node added new one, else continue down in tree adding word, when we come to the end set isEnded property to true
    /// running time: if n is number of charachter in string then O(n)
    ///
    /// - parameter string: string added to tree
    public func insert(string:String){
    
        guard !string.isEmpty else{
            return
        }
        
        var currentNode = root
        
        for character in string.lowercased(){
            if let val = currentNode.childrens[character] {
                currentNode = val
            }else{
                let newNode = TrieNode<Character>()
                currentNode.addChildren(c: character, node: newNode)
                currentNode = newNode
            }
        }
        currentNode.isEnded = true
    }
    
    // MARK:
    // MARK: Search
    
    /// private helper method that take searched string check charachter by charachter and if searched carachter not exist return nil else continue until it find final node.
    /// running time: if n is number of charachter in string then O(n)
    ///
    /// - parameter string: string that is searched
    ///
    /// - return: final node of string or nil if string not exist
    fileprivate func nodeOfSearchString(string:String)->TrieNode<Character>?{
    
        var currentNode = root
        
        for character in string.lowercased(){
            if let val = currentNode.childrens[character] {
                currentNode = val
            }else{
                return nil
            }
        }
        return currentNode
    }
    
    /// searching if prefix exist in tree
    /// running time: if n is number of charachter in string then O(n)
    ///
    /// - parameter prefix: searched prefix
    ///
    /// - return: does prefix exist
    public func prefixSearch(prefix:String)->Bool{
        return nodeOfSearchString(string: prefix.lowercased()) != nil
    }
    
    /// searching if string exist in tree
    /// running time: if n is number of charachter in string then O(n)
    ///
    /// - parameter string: searched string
    ///
    /// - return: does string exist
    public func search(string:String)->Bool{
    
        let node = nodeOfSearchString(string: string.lowercased())
        if node == nil{
            return false
        }
        return node!.isEnded
    }
    
    /// searching for all strings that have some prefix. String can not be empty. First search for node that have some prefix , if not found return nil. If we have some prefix in tree we check recursively each child of node, checking if node is end of word, and for all node that is last node of word, adding that word in array
    /// running time: if n is average number of charachter in found array od string, and l is count of strings found then O(n*l)
    ///
    /// - parameter prefix: prefix for which we searche all strings
    ///
    /// - return: all words for some prefix, if there is no any words for prefix return nil
    public func allStringsForPrefix(prefix:String)->[String]?{
    
        guard prefix.isEmpty == false else {
            return nil
        }
        
        var data = [String]()
        
        let node = nodeOfSearchString(string: prefix.lowercased())
        
        guard node != nil else {
            return nil
        }
        
        allNodeStrings(node: node!, prefix: prefix.lowercased(), data: &data)
    
        return data
    }
    
    /// Private helper method helping finding all string for prefix recursively. For some node check if node is end of word, and if yes add current prefix in data array, than  recursively check each child of that node, and if there are end of word.
    ///
    /// - parameter node: node we check does he end of word
    /// - parameter prefix: current prefix, prefix until this node
    /// - parameter data: array of word we found for some prefix
    fileprivate func allNodeStrings(node:TrieNode<Character>,prefix:String, data:inout [String]){
    
        if node.isEnded == true{
            data.append(prefix.lowercased())
        }
        
        for key in node.childrens.keys{
            let newPrefix = prefix + String(key)
            let child = node.childrens[key]
            allNodeStrings(node: child!, prefix: newPrefix, data: &data)
        }
    }
    
    // MARK:
    // MARK: Delete
    
    /// Deleting word from tree, first searched if string exist, then chack if final node have more charachter if yes set isEnded property to false, else go up and delete all posible node that have only charachter from this string
    ///
    /// - parameter string: string that is deleted
    public func deleteWord(string:String){
    
        let node = nodeOfSearchString(string: string.lowercased())
        if node != nil{
            if node?.childrens.count != 0{
                node!.isEnded = false
            }else{
                deleteUp(fromNode: node!)
            }
        }
    }
    
    /// Deleting all word with some prefix
    ///
    /// - parameter prefix: prefix for every word is deleted
    public func deletePrefix(prefix:String){
        
        let node = nodeOfSearchString(string: prefix.lowercased())
        if node != nil && node !== root{
            let parentCharachter = node!.parentCharachter!
            node!.parent!.removeChild(key: parentCharachter)
            if node!.parent!.isEnded == false {
                deleteUp(fromNode: node!.parent!)
            }
        }
    }
    
    /// Helper private method that take first node need to be deleted go up in tree and chack if more parent node have to be deleted (has only one child)
    ///
    /// - parameter string: first node need to be deleted
    fileprivate func deleteUp(fromNode:TrieNode<Character>){

        guard fromNode.childrens.count == 0 && fromNode !== root else {
            return
        }
        
        var currentNode = fromNode
        var finished = false
        while finished == false {
            let parentCharachter = currentNode.parentCharachter!
            currentNode.parent!.removeChild(key: parentCharachter)
            currentNode = currentNode.parent!
            if currentNode.childrens.count > 0 || currentNode === root || currentNode.isEnded == true{
                finished = true
            }
        }
    }
}
