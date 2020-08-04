//
//  LoadJsonData.swift
//  GRGetReport
//
//  Created by JOJO on 2019/9/10.
//  Copyright © 2019 JOJO. All rights reserved.
//

import Foundation
import SwifterSwift
 

public class LoadJsonData: NSObject {
    
    public static var `default` = LoadJsonData()
    
    public func loadJson<T: Codable>(_: T.Type, name: String, type: String = "json") -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch let error as NSError {
                    print(error)
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    public func loadPlist<T: Codable>(_:T.Type, name:String, type:String = "plist") -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                do {
                    return try PropertyListDecoder().decode(T.self, from: data)
                } catch let error as NSError {
                    print(error)
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}




