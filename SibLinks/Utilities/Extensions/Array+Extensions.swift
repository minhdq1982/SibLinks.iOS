//
//  Array+Extensions.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation

extension NSIndexSet {
    func toArray() -> [Int] {
        var indexes:[Int] = [];
        self.enumerateIndexesUsingBlock { (index:Int, _) in
            indexes.append(index);
        }
        return indexes;
    }
}

extension Array {
    
    func at(index: Int?) -> Element? {
        if let index = index where index >= 0 && index < endIndex {
            return self[index]
        } else {
            return nil
        }
    }
    
    func objectsAtIndexes(indexes: [Int]) -> [Element] {
        let elements: [Element] = indexes.map{ (idx) in
            if idx < self.count {
                return self[idx]
            }
            return nil
            }.flatMap{ $0 }
        return elements
    }
}

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

func nextIndex(x: Int?) -> Int? {
    return x?.successor()
}

func prevIndex(x: Int?) -> Int? {
    return x?.predecessor()
}