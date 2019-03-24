//
//  LocalizedStrings.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

private class Localizator {
    static let sharedInstance = Localizator()
    
    lazy var localizableDictionary: NSDictionary! = {
        if let path = Bundle.main.path(forResource: "PrivaliaCaseStrings", ofType: "strings") {
            return NSDictionary(contentsOfFile: path)
        } else {
            let bundle = Bundle(for: type(of: self))
            let path = bundle.path(forResource: "PrivaliaCaseStrings", ofType: "strings")
            return NSDictionary(contentsOfFile: path!)
        }
    }()
    
    public func localize(string: String) -> String {
        let localizedString = localizableDictionary![string]
        return localizedString as! String
    }
}

extension String {
    public var localize: String {
        let toReturn = Localizator.sharedInstance.localize(string: self)
        return toReturn
    }
}
