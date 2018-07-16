//
//  MainViewController.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import CoreData

extension NumberFormatter {
    static let sharedCurrencyFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return currencyFormatter
    }()
    
    static let sharedDefaultFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        return currencyFormatter
    }()
}

extension DateFormatter {
    static let sharedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a EEEE, d/M/y"
        return dateFormatter
    }()
}



private extension Array where Element == Transaction {
    var transactionCellItems: [TransactionCellItem] {
        return map {
            return TransactionCellItem(
                description: $0.transactionDescription!,
                amount: $0.amount.value,
                date: DateFormatter.sharedDateFormatter.string(from: $0.date!)
            )
        }
    }
}

private extension Array where Element == Transaction {
    var balanceViewItem: BalanceViewItem {
        let balanceValue: Float = unsettledTransactions.balance
        
        let liableParty: String = {
            switch balanceValue.sign.borrower {
            case .me: return "You owe them"
            case .noOne: return "Even-steven"
            case .them: return "They owe you"
            }
        }()
        return BalanceViewItem(
            balance: balanceValue,
            liableParty: liableParty,
            remainingTransactions: "\(unsettledTransactions.count) unsettled transactions"
        )
    }
}

public class MainViewController: UIViewController, AddTransactionViewControllerDelegate, TransactionViewControllerDelegate {
    
    var transactionManager: TransactionManager {
        return TransactionManager.shared
    }
    
    var personId: NSManagedObjectID? {
        didSet {
            title = person?.firstName
        }
    }
    
    var person: Person? {
        guard let personId = personId else { return nil }
        return transactionManager.person(withId: personId)
    }
    
    @IBOutlet var balanceView: BalanceView! {
        didSet {
            reloadBalanceView()
        }
    }
    
    var transactionViewController: TransactionViewController! {
        didSet {
            transactionViewController.delegate = self
            reloadTransactionList()
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedTransactionViewController" {
            transactionViewController = (segue.destination as! TransactionViewController)
        }
    }
    
    @IBAction func addButtonTapped() {
//        showAddTransactionAlert(description: nil, amount: nil)
        showAddViewController()
    }
    
    func showAddViewController() {
        // guard let addNavigationController = UIStoryboard(name: "Add Transaction", bundle: nil).instantiateInitialViewController() as? UINavigationController, let addViewController = addNavigationController.topViewController as? AddTransactionViewController else { return }
        
        let addViewController = AddTransactionFormViewController()
        let addNavigationController = UINavigationController(rootViewController: addViewController)

        addViewController.delegate = self
        addViewController.personId = personId
        
        present(addNavigationController, animated: true, completion: nil)
    }
    
    private func reloadBalanceView() {
        guard let person = person, let transactions = person.transactions?.array as? [Transaction] else { return }
        balanceView.viewItem = transactions.balanceViewItem
    }
    
    private func reloadTransactionList() {
        transactionViewController.cellItems = sortedTransactions!.transactionCellItems
        transactionViewController.reloadData()
    }
    
    private func reloadViews() {
        reloadBalanceView()
        reloadTransactionList()
    }
    
    var sortedTransactions: [Transaction]? {
        guard let person = person, let unsortedTransactions = person.transactions?.array as? [Transaction] else { return nil }
        
        return unsortedTransactions.sorted(by: {$0.date < $1.date })
    }
    
    // MARK: Conformance -
    
    // MARK: AddTransactionViewControllerDelegate
    
    func userDidAddTransaction(in viewController: AddTransactionFormViewController) {
        reloadViews()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidUpdateTransaction(in viewController: AddTransactionFormViewController) {
        reloadViews()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidCancel(in viewController: AddTransactionFormViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TransactionViewControllerDelegate
    
    func userDidSelectTransaction(at index: Int) {
        let addViewController = AddTransactionFormViewController()
        let addNavigationController = UINavigationController(rootViewController: addViewController)
        
        addViewController.delegate = self
        addViewController.personId = personId
        addViewController.transactionId = sortedTransactions![index].objectID
        
        present(addNavigationController, animated: true, completion: nil)
    }
    
    func userDidDeleteTransaction(at index: Int) {
        guard let person = person else { return }
        
        let transaction = person.transactions![index] as! Transaction
        transactionManager.removeTransaction(withId: transaction.objectID)
        
        reloadBalanceView()
    }
}

