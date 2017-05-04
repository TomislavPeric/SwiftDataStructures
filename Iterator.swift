//
//  Iterator.swift
//  swiftTest
//
//  Created by Tomislav Profico on 07/12/16.
//  Copyright © 2016 Tomislav Profico. All rights reserved.
//

import UIKit

protocol Iterator {
    func hasNext()->Bool
    func next()->Any?
    
    func hasPrevius()->Bool
    func previus()->Any?
}
