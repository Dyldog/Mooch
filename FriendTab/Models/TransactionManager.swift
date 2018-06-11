//
//  TransactionManager.swift
//  FriendTab
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

class TransactionManager {
    private(set) lazy var transactions: [Transaction] = [
        .init(id: newTransactionId(), amount: 101.23, description: "All da beeerrrrzzzzz"),
        .init(id: newTransactionId(), amount: -75.99, description: "Some nachos"),
        .init(id: newTransactionId(), amount: 1000000, description: "Present for Sarah"),
    ]
    
    func addTransaction(withDescription description: String, amount: Float) {
        transactions.append(Transaction(id: newTransactionId(), amount: amount, description: description))
    }
    
    func removeTransaction(_ transaction: Transaction) {
        transactions.removeAll(where: { $0.id == transaction.id })
    }
    
    private func newTransactionId() -> String {
        return NSUUID().uuidString
    }
}
