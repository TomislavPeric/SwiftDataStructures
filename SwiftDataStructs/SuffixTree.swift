//
//  SuffixTree.swift
//  swiftTest
//

import UIKit

class SuffixTreeNode{

    var link : SuffixTreeNode?
    var childs : [String : SuffixTreeNode]
    
    var start:Int
    var index:Int
    var end:End
    
    var indexesOfString : [Int] = []
    
    init(start:Int, end:End) {
        self.start = start
        self.end = end
        self.index = -1
        self.childs = [:]
    }
    
    func toString(data:[Character])->String{
    
        var string = ""
        
        for i in start...end.end{
            string.append(data[i])
        }
        
        return string
    }
}

class End {
    
    var end:Int
    init(end:Int) {
        self.end = end
    }
}

class SuffixTree {
    
    internal var root : SuffixTreeNode
    fileprivate var end : End
    fileprivate var remaining : Int = 0
    internal var data : [Character]
    
    fileprivate var activeNode: SuffixTreeNode
    fileprivate var currentLenght : Int = 0
    fileprivate var currentEdge : Int = -1
    
    fileprivate var isBuild = false
    
    ///constructor that take string from which we build suffix tree
    ///
    ///- parameter chars: string for which we build suffix tree
    init(chars:[Character]) {
        
        root = SuffixTreeNode.init(start: 1, end: End(end:0))
        end = End(end:-1)
        data = chars
        data.append("$")
        self.activeNode = root
    }
    
    /// number of charachter in string
    func count()->Int{
        return data.count - 1
    }
    
    // MARK:
    // MARK: Build
    
    /// build tree
    func build(){
    
        isBuild = true
        for index in 0..<data.count{
            remaining += 1
            var a : SuffixTreeNode? = nil
            checkNodes(index: index, lastCreatedNode: &a)
            end.end += 1
        }
    }
    
    /// for each charachter in string check new node
    ///
    /// - parameter index: index of current charachter
    /// - parameter lastCreatedNode: we need track last create node so we can set link on new created node.
    fileprivate func checkNodes(index:Int, lastCreatedNode:inout SuffixTreeNode?){
        
        if remaining == 0{
            return
        }
        
        if currentLenght != 0{
            
            let nextCharIndex = nextCharachterIndex(index:index)
            let currentNode = activeNode.childs[String(data[currentEdge])]
            if nextCharIndex == -1 {
                
                if currentNode!.end !== end {
                    currentNode!.childs[String(data[index])] = SuffixTreeNode.init(start: index, end: end)
                    if (lastCreatedNode != nil) {
                        lastCreatedNode!.link = currentNode;
                    }
                    lastCreatedNode = currentNode
                }
                
                if(activeNode !== root){
                    activeNode = activeNode.link ?? root
                }else{
                    currentEdge += 1
                    currentLenght -= 1
                }
                checkNodes(index: index, lastCreatedNode: &lastCreatedNode)
            }
            
            else if data[nextCharIndex] == data[index]{
                
                let current = activeNode.childs[String(data[currentEdge])]
                if(lastCreatedNode != nil){
                    lastCreatedNode!.link = current
                }

                if (current!.end.end - current!.start) < currentLenght{
                    activeNode = current!
                    currentLenght = currentLenght - (current!.end.end - current!.start)
                    currentEdge = current!.childs[String(data[index])]!.start
                }else{
                    currentLenght += 1
                }
                
            }else{
                
                remaining -= 1
                
                let oldEnd = currentNode!.end.end
                let fullEnd = currentNode!.end === end
                currentNode!.end = End(end: currentNode!.start + (currentLenght - 1))
                let childs = currentNode!.childs
                currentNode!.childs.removeAll()
                currentNode!.childs[String(data[index])] = SuffixTreeNode.init(start: index, end: end)
                currentNode!.childs[String(data[currentNode!.start + currentLenght])] = SuffixTreeNode.init(start: currentNode!.start + currentLenght, end: fullEnd ? end : End(end:oldEnd))
                currentNode!.childs[String(data[currentNode!.start + currentLenght])]!.childs = childs
                if (lastCreatedNode != nil) {
                    lastCreatedNode!.link = currentNode
                }
                //set this guy as lastCreatedInternalNode and if new internalNode is created in next extension of this phase
                //then point suffix of this node to that node. Meanwhile set suffix of this node to root.
                lastCreatedNode = currentNode
                currentNode!.link = root
                
                if activeNode !== root{
                    activeNode = activeNode.link ?? root
                }else{
                    currentEdge += 1
                    currentLenght -= 1
                }
                checkNodes(index: index, lastCreatedNode: &lastCreatedNode)
            }
            
        }else if let node = activeNode.childs[String(data[index])]{
            currentEdge = node.start
            currentLenght += 1
        }else{
            root.childs[String(data[index])] = SuffixTreeNode.init(start: index, end: end)
            remaining -= 1
            checkNodes(index: index, lastCreatedNode: &lastCreatedNode)
        }
    }
    
    /// charachter of next index
    fileprivate func nextCharachterIndex(index:Int)->Int{
        
        let currentNode = activeNode.childs[String(data[currentEdge])]
    
        if currentNode!.end.end - currentNode!.start >= currentLenght {
           return currentNode!.start + currentLenght
        }
        
        if(currentNode!.end.end - currentNode!.start + 1 == currentLenght){
            if(currentNode!.childs[String(data[index])] != nil){
                return index
            }else{
                return -1
            }
        }
        else{
            activeNode = currentNode!
            currentLenght = currentLenght - (currentNode!.end.end - currentNode!.start) - 1
            currentEdge = currentEdge + currentNode!.end.end - currentNode!.start  + 1
            return nextCharachterIndex(index: index)
        }
    }
    
    // MARK:
    // MARK: Traverse and set indexes
    
    /// set index of all suffix, if we have visitor than visit every suffix. alse return all sufixes if needed
    ///
    /// - parameter node: node which we check to set index.
    /// - parameter val: size of suffix in current node
    /// - parameter size: size of current string
    /// - parameter suffixes: all found suffix
    /// - parameter currentSuffix: current suffix
    /// - parameter visitor: visitor that visit all sufixes
    fileprivate func setIndexes(node:SuffixTreeNode?, val: Int, size:Int, sufixes:inout Array<String>?, currentSuffix:String?, visitor:Visitor<(suffix:String, index:Int)>?){
    
        guard node !== nil else {
            return
        }
        let newValue = val + node!.end.end - node!.start + 1
        
        if node!.childs.count == 0{
            if sufixes != nil{
                sufixes![size - newValue] = currentSuffix!
            }
            if visitor != nil{
                visitor?.visit(object: (currentSuffix!, size - newValue))
            }
            node!.index = size - newValue
        }else{
            for child in node!.childs{
                var newSuffix = currentSuffix
                if sufixes != nil{
                    for i in child.value.start...child.value.end.end{
                        if i != end.end{ newSuffix?.append(data[i])}
                    }
                }
                setIndexes(node: child.value, val: newValue, size: size, sufixes: &sufixes, currentSuffix:newSuffix, visitor: visitor)
            }
        }
    }
    
    // MARK:
    // MARK: All sufixes
    
    ///get all suffixes of tree
    func allSuffixes()->Array<String>?{
        
        guard isBuild else {
            return nil
        }
        
        guard data.count > 0 else {
            return nil
        }
    
        var suffixes : Array<String>? = Array<String>.init(repeating: "", count: data.count)
        setIndexes(node: root, val: 0, size: data.count, sufixes: &suffixes, currentSuffix:"", visitor: nil)
        suffixes!.removeLast()
        return suffixes
    }
    
    /// visit all sufixes in tree
    func visitSuffixes(visitor:Visitor<(suffix:String, index:Int)>){
    
        var suffixes : Array<String>? = Array<String>.init(repeating: "", count: data.count)
        setIndexes(node: root, val: 0, size: data.count, sufixes: &suffixes, currentSuffix:"", visitor: visitor)
    }
    
    // MARK:
    // MARK: Chack substring
    
    /// Check if string is sibstring of tree
    ///
    /// - parameter patternString: substring which we search
    ///
    /// - return: is string substring of tree
    func isSubstring(patternString:[Character])->Bool{
        
        guard patternString.count > 0 else {
            return false
        }
    
        return searchSubstringTraversal(node: root, searchedString: patternString, currentCharachterIndex: 0)
    }
    
    /// helper for searching substring
    fileprivate func searchSubstringTraversal(node:SuffixTreeNode?, searchedString:[Character], currentCharachterIndex:Int)->Bool{
        
        var suffixData : [Int]?
        return searchSubstringOccurrences(node: node, searchedString: searchedString, currentCharachterIndex: currentCharachterIndex, suffixData: &suffixData)
    }
    
    ///search for substring occurrences
    ///
    /// - parameter node: current node to check
    /// - parameter searchedString: searched substring
    /// - parameter currentCharachterIndex: current index of searched substring
    /// - parameter suffixData: found substring start indexes
    ///
    /// - return is substring in tree
    fileprivate func searchSubstringOccurrences(node:SuffixTreeNode?, searchedString:[Character], currentCharachterIndex:Int, suffixData:inout [Int]?)->Bool{
        
        guard node !== nil else {
            return suffixData != nil && suffixData!.count > 0
        }
        
        if suffixData == nil{
            guard currentCharachterIndex < searchedString.count else {
                return suffixData != nil && suffixData!.count > 0
            }
        }
        
        var currentIndex = currentCharachterIndex
        
        if node !== root{
            for i in node!.start...node!.end.end{
                
                if searchedString[currentIndex] != data[i]{
                    return suffixData != nil && suffixData!.count > 0
                }
                
                if currentIndex > 0 && data[i] == searchedString[0]{
                    _ = searchSubstringOccurrences(node: node!, searchedString: searchedString, currentCharachterIndex: 0, suffixData: &suffixData)
                }
                
                if currentIndex == searchedString.count - 1{
                    if suffixData == nil{
                        return true
                    }else{
                        
                        if i == node!.end.end || node!.childs.count != 0{
                            addAllOccuracesOfNode(node: node, val: node!.start, size: data.count, sufixes: &suffixData!, firstIndex: (i - (searchedString.count - 1)))
                            return suffixData != nil && suffixData!.count > 0
                        }else{
                            suffixData!.insertWithNoRepaeatingElement(element: i - (searchedString.count - 1), orderFunction: <)
                        }
            
                        currentIndex = -1
                    }
                }
                currentIndex += 1
            }
        }
        
        
        if let child = node!.childs[String(searchedString[currentIndex])]{
            if searchSubstringOccurrences(node: child, searchedString: searchedString, currentCharachterIndex: currentIndex, suffixData: &suffixData){
                if suffixData == nil{
                    return true
                }
            }
        }
        
        return suffixData != nil && suffixData!.count > 0
    }
    
    /// add all leaf of node
    fileprivate func addAllOccuracesOfNode(node:SuffixTreeNode?, val: Int, size:Int, sufixes:inout [Int], firstIndex:Int){
        
        guard node !== nil else {
            return
        }
        
        let newValue = val + node!.end.end - node!.start + 1
        
        if node!.childs.count == 0{
            sufixes.insertWithNoRepaeatingElement(element: size - (newValue - firstIndex), orderFunction: <)
        }else{
            for child in node!.childs{
                addAllOccuracesOfNode(node: child.value, val: newValue, size: size, sufixes: &sufixes, firstIndex: firstIndex)
            }
        }
    }
    
    // MARK:
    // MARK: All Occurrences
    
    /// find all start indexes of serch string
    ///
    /// - parameter search substring
    ///
    /// - return: all start indexes of search substring
    func allOccurrencesOfSubstring(patternString:[Character])->[Int]?{
        
        guard patternString.count > 0 else {
            return nil
        }
    
        var data : [Int]? = []
        _ = searchSubstringOccurrences(node: root, searchedString: patternString, currentCharachterIndex: 0, suffixData: &data)
        return data
    }
    
    // MARK:
    // MARK: Longest repeating substring
    
    ///find longest repeting substring
    func longestRepeatingSubstring()->String?{
    
        var resultSize = 0
        var resultStart = -1
        var longestDepth = -1
        var result = ""
        longestRepeatingSubstring(node: root, val: 0, size: data.count, resultStart: &resultStart, resultSize: &resultSize, currentStartIndex: 0, longestSize: &longestDepth, currentSize: 0, isFromRoot:false)
        
        guard resultSize > 0 else {
            return nil
        }
        
        for i in resultStart...resultStart + (resultSize - 1){
            result.append(data[i])
        }
        return result
    }
    
    ///longest substring helper
    fileprivate func longestRepeatingSubstring(node:SuffixTreeNode, val: Int, size:Int, resultStart:inout Int,resultSize:inout Int, currentStartIndex:Int, longestSize:inout Int, currentSize:Int, isFromRoot:Bool){
        
        let newValue = val + node.end.end - node.start + 1
        
        if node.childs.count == 0{
            return
        }else{
            let newStartIndex = node.start
            let newSize = currentSize + (node.end.end - (node.start - 1))
            let cStart = isFromRoot ? newStartIndex : currentStartIndex
            if longestSize < newSize{
                longestSize = newSize
                resultStart = currentStartIndex
                resultSize = newSize
            }
            for child in node.childs{
                
                longestRepeatingSubstring(node: child.value, val: newValue, size: size, resultStart: &resultStart, resultSize:&resultSize, currentStartIndex: cStart, longestSize: &longestSize, currentSize:newSize, isFromRoot: node===root)
            }
        }
    }
    
    // MARK:
    // MARK: Build suffix array
    
    /// from suffix tree build suffix array
    func buildSuffixArray()->SuffixArray{
        
        assert(isBuild, "Suffix tree is not yet build")
        return SuffixArray.init(suffixTree: self)
    }
    
}
