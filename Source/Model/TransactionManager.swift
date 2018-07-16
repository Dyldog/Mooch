//
//  TransactionManager.swift
//  FriendTab
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation
import CoreData

class TransactionManager {
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print(error)
        }
        
        return coordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    static var shared = TransactionManager()
    
//    private lazy var dummyTransactions: [Transaction] = [
//        .init(id: newTransactionId(), amount: 101.23, description: "All da beeerrrrzzzzz"),
//        .init(id: newTransactionId(), amount: -75.99, description: "Some nachos"),
//        .init(id: newTransactionId(), amount: 1000000, description: "Present for Sarah"),
//    ]
    
    var people: [Person] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Person", in: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        return try! self.managedObjectContext.fetch(fetchRequest) as! [Person]
        // TODO: Handle error
    }
        
//    [
//        .init(id: newTransactionId(), name: ("Sarah", "Wise"), transactions: dummyTransactions)
//    ]
    
    
    @discardableResult func addPerson(firstName: String, lastName: String) -> Person {
        let newPerson = Person(context: managedObjectContext) // NSManagedObject(entity: entityDescription!, insertInto: self.managedObjectContext)
        newPerson.firstName = firstName
        newPerson.lastName = lastName
        try? newPerson.managedObjectContext?.save() // TODO: Handle errors
        
//        let newPerson = Person(id: newTransactionId(), name: (firstName, lastName), transactions: [])
//        people.append(newPerson)
//        return newPerson
        
        return newPerson
    }
    
    @discardableResult func addTransaction(withDescription description: String, amount: Amount, date: Date, settlementDate: Date? = nil, forPersonWithId personId: NSManagedObjectID) -> Transaction? {
        guard let personManagedObject = try? managedObjectContext.existingObject(with: personId), let person = personManagedObject as? Person else { return nil }
        let newTransaction = Transaction(context: managedObjectContext)
        newTransaction.transactionDescription = description
        newTransaction.amount = amount
        newTransaction.date = date
        person.addToTransactions(newTransaction)
        try? person.managedObjectContext?.save() // TODO: Handle errors
        
        return newTransaction
    }
    
    @discardableResult func updateTransaction(_ transaction: Transaction, withDescription description: String, amount: Amount, date: Date, settlementDate: Date? = nil) -> Transaction? {

        transaction.transactionDescription = description
        transaction.amount = amount
        transaction.date = date
        transaction.settlementDate = settlementDate
        try? transaction.managedObjectContext?.save() // TODO: Handle errors
        
        return transaction
    }
    
    func person(withId id: NSManagedObjectID) -> Person? {
        guard let personManagedObject = try? managedObjectContext.existingObject(with: id), let person = personManagedObject as? Person else { return nil }
        
        return person
    }
    
    func transaction(withId id: NSManagedObjectID) -> Transaction? {
        guard let transactionManagedObject = try? managedObjectContext.existingObject(with: id), let transaction = transactionManagedObject as? Transaction else { return nil }
        
        return transaction
    }
    
    func removeTransaction(withId transactionId: NSManagedObjectID) {
        guard let transaction = transaction(withId: transactionId) else { return }
        managedObjectContext.delete(transaction)
        try? managedObjectContext.save() // TODO: Handle errors
    }
    
    private func newTransactionId() -> String {
        return NSUUID().uuidString
    }
}
