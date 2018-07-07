//
//  Transaction.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

struct Transaction {
    let id: String
    let amount: Float
    let description: String
}

class Person: NSObject {
    let id: String
    let name: (String, String)
    var transactions: [Transaction]
    
    init(id: String, name: (String, String), transactions: [Transaction]) {
        self.id = id
        self.name = name
        self.transactions = transactions
    }
}
