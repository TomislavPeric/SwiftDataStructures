//
//  GeneralizedSuffixTree.swift
//  swiftTest
//

import UIKit


class GeneralizedSuffixTree: SuffixTree {
    
    fileprivate var map : [Int : String] = [:]
    fileprivate var placeOf$ : [Int] = []
    
    fileprivate var N :Int?
    
    /// We take array of strings, concat all strings with $num#. num is index of string in array. Then append all strings together, store every string in map, and finaly init tree with super call
    ///
    /// - parameter strings : array of string that is inserted in tree
    init(strings: [String]) {
        
        var string = ""
        var i = 0
        var last$Position = 0
        for chars in strings{
            last$Position += chars.characters.count
            string.append(chars)
            string.append("$")
            placeOf$.append(last$Position)
            string.append(String(i))
            string.append("#")
            last$Position += 2
            last$Position += String(i).characters.count
            map[i] = chars
            i += 1
        }
        
        super.init(chars: Array(string.characters))
    }
    
    // MARK:
    // MARK: Build
    
    ///overide build method, and after building remove all nodes that are not needed
    override func build() {
        super.build()
        removeHelperNodes()
    }
    
    ///First remove all node that is not needed, and then change end of leaf nods, end set indexes of string that this nodes belong.
    fileprivate func removeHelperNodes(){
        
        guard root.childs.count != 0 else{
            return
        }
    
        for child in root.childs{
            checkIfNodeNeedToBeDelete(node: child.value,parent: root, charachter: child.key)
        }
        
        for child in root.childs{
           traverseAndRemoveAfter$(node: child.value, parent: root, charchter: child.key)
        }
    }
    
    /// First if node start with $ or # we do not need this node, delete this node and return. if node start with letter return, we do not need more checking. else if node start with numerich charachter we need to check (with regex) if this node in start have number and after #, if yes we do not need this node, so delete it and return, else we check if node have any latter charachter in self if yes retur else we need to check childs node with this method.
    ///
    /// - parameters node : current node to check
    /// - parameters parent : parent node of current node that is checking. This is need so we can delete current node if needed.
    /// - parameters charachter : charachter which current node start
    fileprivate func checkIfNodeNeedToBeDelete(node:SuffixTreeNode, parent:SuffixTreeNode, charachter:String){
        
        if charachter == "$" || charachter == "#"{
            parent.childs[charachter] = nil
            return
        }
        if Int(charachter) == nil {
            return
            
        }
    
        let string = node.toString(data: self.data)
        
        let pat = "\\d+#"
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count))
        
        if matches.count > 0{
        
            parent.childs[charachter] = nil
            return
        }
        
        let pat2 = "\\w+"
        let regex2 = try! NSRegularExpression(pattern: pat2, options: [])
        let matches2 = regex2.matches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count))
        
        if matches2.count == 0{
            
            for child in parent.childs{
                checkIfNodeNeedToBeDelete(node: child.value,parent: node, charachter: child.key)
            }
            
            if node.childs.count == 0{
                parent.childs[charachter] = nil
            }
        }
    }

    /// Using binary search we search if node contains $. We have all $ position stored when we init tree, so we can faster search for $-ars.
    ///
    /// - parameters startRange - start index of current node
    /// - parameters endRange - end index of current node
    ///
    /// - return: position of $ if exist else return -1
    fileprivate func searchFor$(startRange:Int,endRange:Int)->Int{
    
        var low = 0
        var high = self.placeOf$.count - 1
        while low <= high {
            let mid = (low + high)/2
            if self.placeOf$[mid] < startRange {
                low = mid + 1
            } else if self.placeOf$[mid] > startRange {
                high = mid - 1
            } else {
                low = mid
                break
            }
        }
        while low < self.placeOf$.count && self.placeOf$[low] <= endRange{
        
            if (self.placeOf$[low] >= startRange){
                return self.placeOf$[low]
            }
            low += 1
        }
        return -1
    }
    
    /// If node start with # remove it. if node start with $ and is not leaf delete it and all childs, and end all childs indexes to parent indexes of string. else if node start with number check if it have # after number if yes delete this node. else if node is leaf take dollar position, get number after $ and before # save it in indexesOfString, end set end to be dolarPosition - 1. else if node is node leaf traverse all it child with this methode.
    ///
    /// - parameters node : current node to check
    /// - parameters parent : parent node of current node that is checking. This is need so we can delete current node if needed.
    /// - parameters charachter : charachter which current node start
    fileprivate func traverseAndRemoveAfter$(node:SuffixTreeNode, parent:SuffixTreeNode, charchter:String){
    
        if charchter == "#"{
            parent.childs[charchter] = nil
            return
        }else if charchter == "$" && node.childs.count != 0{
            
            remove$Childs(node: node, parent: parent, currentNum: "")
            parent.childs[charchter] = nil
            return
        }
        
        if (Int(charchter) != nil){
            let string = node.toString(data: data)
            let pat = "^\\d+#"
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in:string , options: [], range: NSRange(location: 0, length: string.characters.count))
            
            if matches.count > 0{
                
                parent.childs[charchter] = nil
                return
            }
        }
        
        if node.childs.count == 0{
            let dollarPosition = searchFor$(startRange: node.start, endRange: node.end.end)
            if dollarPosition == -1{
                return
            }
            
            var num = ""
            var currentChar = data[dollarPosition + 1]
            var currentPosition = dollarPosition + 1
            while currentChar != "#" {
                num.append(currentChar)
                currentPosition += 1
                currentChar = data[currentPosition]
            }
            
            if dollarPosition == node.start{
                parent.indexesOfString.append(Int(num)!)
                parent.childs[charchter] = nil
            }else{
                node.end = End.init(end: dollarPosition - 1)
                node.indexesOfString.append(Int(num)!)
            }
        }else{
        
            for child in node.childs{
                traverseAndRemoveAfter$(node: child.value, parent: node, charchter: child.key)
            }
        }
    }
    
    /// If node start with $ and is not leaf delete it and all childs, and end all childs indexes to parent indexes of string.
    ///
    /// - parameters node : current node to check
    /// - parameters parent : parent node of current node that is checking. This is need so we can delete current node if needed.
    /// - parameters charachter : charachter which current node start
    fileprivate func remove$Childs(node:SuffixTreeNode, parent:SuffixTreeNode, currentNum:String){
        
        var currentNumHelper = currentNum
        var finished = false
        for i in node.start...node.end.end {
            let char = data[i]
            if (char == "$"){
                
            }else if (char == "#"){
                finished = true
                break
            }else{
                currentNumHelper.append(char)
            }
        }
        
        if finished{
            parent.indexesOfString.append(Int(currentNumHelper)!)
            
        }else{
            for child in node.childs{
                remove$Childs(node: child.value, parent: parent, currentNum: currentNumHelper)
            }
        }
    
    }
    
    // MARK:
    // MARK: All string contains substring
    
    /// Public method, get all strings contains some substring. Found node with substring and add with string indexes of this node and his child return all string that contain this node.
    ///
    /// - parameter patternString: substring to check
    ///
    /// - return: set of found strings
    func allStringsContainsSubstring(patternString:[Character]) -> Set<String>?{
    
        guard patternString.count > 0 else {
            return nil
        }
        
        var node = root
        var currentCharIndex = 0
        while currentCharIndex < patternString.count{
        
            let char = patternString[currentCharIndex]
            if let nHelp =  node.childs[String(char)]{
                node = nHelp
            }else{
                return nil
            }
            
            for i in node.start...node.end.end{
                if (data[i] != patternString[currentCharIndex]){
                    return nil
                }
                currentCharIndex += 1
                
                if currentCharIndex >= patternString.count{
                    break
                }
            }
        }
        
        var set = Set<String>()
        addAllStringsOfNode(node: node, data: &set)
        return set
    }
    
    /// Traverse all nod child and add with all indexesOfString and map in which is stored all strings get all string conataining substring
    ///
    /// - parameter node: currentNode to check
    /// - parameter data: array in which are stored strings
    fileprivate func addAllStringsOfNode(node:SuffixTreeNode, data:inout Set<String>){
        
        for i in node.indexesOfString{
            data.insert(map[i]!)
        }
        
        for child in node.childs{
            addAllStringsOfNode(node: child.value, data: &data)
        }
    }
    
    // MARK:
    // MARK: Longest common substring
    
    /// Find longest common substring of all string in array
    ///
    /// - return: longest common substring if exist
    func longestCommonSubstring() -> String?{
        
        guard self.data.count > 0 else {
            return nil
        }
    
        var data : [String] = []
        var palindroms : [String]? = nil
        traverseAndSearchCommonSubstrings(currentNode: root, currentSuffix: "", data: &data, palindromData: &palindroms)
        var resultString : String?
        var currentCount = 0
        for string in data{
            if string.characters.count > currentCount{
                currentCount = string.characters.count
                resultString = string
            }
        }
        return resultString
    }
    
    // MARK:
    // MARK: All common substrings
    
    /// Find all common substring of all string in array
    ///
    /// - return: all common substring if exists
    func allCommonSubstring() -> [String]?{
        
        guard self.data.count > 0 else {
            return nil
        }
        
        var data : [String] = []
        var palindroms : [String]? = nil
        traverseAndSearchCommonSubstrings(currentNode: root, currentSuffix: "", data: &data, palindromData: &palindroms)
        return data;
    }
    
    /// Traverse through tree and if needed find all coomon substring and palindroms
    @discardableResult
    fileprivate func traverseAndSearchCommonSubstrings(currentNode:SuffixTreeNode, currentSuffix:String, data: inout [String], palindromData: inout [String]?)->(set:Set<Int>,ends:[Int]){
    
        var newSuffix = currentSuffix
        
        if currentNode !== root{
            newSuffix.append(currentNode.toString(data: self.data))
        }
        
        var indexes = Set<Int>()
        var ends : [Int] = []
        
        for ind in currentNode.indexesOfString{
            indexes.insert(ind)
        }
        
        if currentNode.childs.count == 0{
            ends.append(currentNode.end.end)
        }else if currentNode.indexesOfString.count != 0{
            for i in currentNode.indexesOfString{
                ends.append(((N! + 3) * i) + (N! - 1))
            }
        }
        
        for child in currentNode.childs{
            let indexesOfChild = traverseAndSearchCommonSubstrings(currentNode: child.value, currentSuffix: newSuffix, data: &data, palindromData: &palindromData)
            
            for ind in indexesOfChild.set{
                indexes.insert(ind)
            }
            
            for ind in indexesOfChild.ends{
                ends.append(ind)
            }
        }
        
        
        if indexes.count == map.count && !newSuffix.isEmpty{
            data.append(newSuffix)
            
            if palindromData != nil && newSuffix.characters.count > 1{
                for end in ends{
                    let lenght = newSuffix.characters.count - 1
                    let start = end - lenght
                    
                    if start > N!{
                        continue
                    }
                    
                    for e in ends{
                        let start2 = e - lenght
                        let nextStart = (N! + 3)
                        let startSecond = (N! - end) - 1
                        if start2 == nextStart + startSecond{//26 - start == start2
                            palindromData!.append(newSuffix)
                        }
                    }
                }
            }
        }
        let diff = (currentNode.end.end - currentNode.start) + 1
        ends = ends.map{ $0 - diff }
        
        return (indexes,ends)
    }
    
    // MARK:
    // MARK: Find palindromes
    
    /// Class public method that take one string reverse it create tree with this two and find palindrom of string if exist.
    ///
    /// - paramater: string for which we search palindrom
    ///
    /// - return: palindrom if exist
    class func longestPalindromicSubstring(string:String)->String?{
        
        guard !string.isEmpty else {
            return nil
        }
        
        let reversed = string.characters.reversed()
        let tree = GeneralizedSuffixTree.init(strings: [string, String(reversed)])
        tree.N = string.characters.count
        tree.build()
        var data : [String] = []
        var palindroms : [String]? = []
        tree.traverseAndSearchCommonSubstrings(currentNode: tree.root, currentSuffix: "", data: &data, palindromData: &palindroms)
        
        var resultString : String?
        var currentCount = 0
        for string in palindroms!{
            if string.characters.count > currentCount{
                currentCount = string.characters.count
                resultString = string
            }
        }
        return resultString
    }
    
    // MARK:
    // MARK: Override not supported methods
    
    override func allSuffixes() -> Array<String>? {
        // NOT SUPPORTED FOR NOW
        return nil
    }
    
    override func visitSuffixes(visitor: Visitor<(suffix: String, index: Int)>) {
        // NOT SUPPORTED FOR NOW
    }
    
    override func allOccurrencesOfSubstring(patternString: [Character]) -> [Int]? {
        // NOT SUPPORTED FOR NOW
        return nil
    }
    
    override func longestRepeatingSubstring() -> String? {
        // NOT SUPPORTED FOR NOW
        return nil
    }
    
    override func buildSuffixArray() -> SuffixArray {
        // NOT SUPPORTED FOR NOW
        assert(false)
    }
    
}
