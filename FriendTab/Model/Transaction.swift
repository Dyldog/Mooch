//
//  Transaction.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

struct Transaction_v1 {
    let id: String
    let amount: Float
    let description: String
}

class Person_v1: NSObject {
    let id: String
    let name: (String, String)
    var transactions: [Transaction]
    
    init(id: String, name: (String, String), transactions: [Transaction]) {
        self.id = id
        self.name = name
        self.transactions = transactions
    }
}
