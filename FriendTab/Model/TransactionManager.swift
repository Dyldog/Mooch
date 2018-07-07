//
//  TransactionManager.swift
//  FriendTab
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

class TransactionManager {
    
    static var shared = TransactionManager()
    
    private lazy var dummyTransactions: [Transaction] = [
        .init(id: newTransactionId(), amount: 101.23, description: "All da beeerrrrzzzzz"),
        .init(id: newTransactionId(), amount: -75.99, description: "Some nachos"),
        .init(id: newTransactionId(), amount: 1000000, description: "Present for Sarah"),
    ]
    
    private(set) lazy var people: [Person] = [
        .init(id: newTransactionId(), name: ("Sarah", "Wise"), transactions: dummyTransactions)
    ]
    
    
    @discardableResult func addPerson(firstName: String, lastName: String) -> Person {
        let newPerson = Person(id: newTransactionId(), name: (firstName, lastName), transactions: [])
        people.append(newPerson)
        return newPerson
    }
    
    @discardableResult func addTransaction(withDescription description: String, amount: Float, forPersonWithId personId: String) -> Transaction? {
        guard let person = person(withId: personId) else { return nil }
        let newTransaction = Transaction(id: newTransactionId(), amount: amount, description: description)
        person.transactions.append(newTransaction)
        return newTransaction
    }
    
    func person(withId id: String) -> Person? {
        return people.first(where: { $0.id == id })
    }
    
    func removeTransaction(withId transactionId: String, forPersonWithId personId: String) {
        guard let person = person(withId: personId) else { return }
        
        person.transactions.removeAll(where: { $0.id == transactionId })
    }
    
    private func newTransactionId() -> String {
        return NSUUID().uuidString
    }
}
