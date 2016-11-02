//
//  AlgoReqeust.swift
//  AlgorithmiaSwiftDemo
//
//  Created by Erik Ilyin on 11/1/16.
//  Copyright © 2016 algorithmia. All rights reserved.
//

import Foundation

class AlgoEntity {
    
    func body() -> Data? {
        return Data()
    }
    
}

class AlgoStringEntity:AlgoEntity {
    var entity:String
    
    init(entity:String) {
        self.entity = entity
    }
    
    override func body() -> Data? {
        return entity.data(using: String.Encoding.utf8)
    }
}