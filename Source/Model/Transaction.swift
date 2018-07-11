//
//  Transaction.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

extension Array where Element == Transaction {
    var unsettledTransactions: [Transaction] {
        return filter { $0.settlementDate == nil }
    }
    
    var balance: Float {
        return self.reduce(0, { $0 + $1.amount })
    }
    
    var unsettledBalance: Float {
        return self.unsettledTransactions.balance
    }
}

extension Person {
    var transactionsArray: [Transaction] {
        return self.transactions?.array as? [Transaction] ?? []
    }
}


