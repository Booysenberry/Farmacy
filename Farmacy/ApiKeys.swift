//
//  ApiKeys.swift
//  StrainPlus
//
//  Created by Brad Booysen on 25/02/20.
//  Copyright © 2020 Booysenberry. All rights reserved.
//

import Foundation

// Wrapper for obtaining keys from keys.plist
func valueForAPIKey(keyname:String) -> String {
    // Get the file path for keys.plist
    let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist")
    
    // Put the keys in a dictionary
    let plist = NSDictionary(contentsOfFile: filePath!)
    
    // Pull the value for the key
    let value:String = plist?.object(forKey: keyname) as! String
    
    return value
}
