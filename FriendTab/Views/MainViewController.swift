//
//  MainViewController.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

extension NumberFormatter {
    static let sharedCurrencyFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return currencyFormatter
    }()
}

private extension Array where Element == Transaction {
    var transactionCellItems: [TransactionCellItem] {
        return map {
            return TransactionCellItem(
                description: $0.description,
                amount: NumberFormatter.sharedCurrencyFormatter.string(from: $0.amount as NSNumber)!
            )
        }
    }
}

private extension Array where Element == Transaction {
    var balanceViewItem: BalanceViewItem {
        let balanceValue: Float = reduce(0, { $0 + $1.amount })
        
        let liableParty: String = {
            switch balanceValue {
            case ..<0.0: return "You owe them"
            case 0.0: return "Even-steven"
            default: return "They owe you"
            }
        }()
        return BalanceViewItem(
            balance: NumberFormatter.sharedCurrencyFormatter.string(from: balanceValue as NSNumber)!,
            liableParty: liableParty,
            remainingTransactions: "\(count) unsettled transactions"
        )
    }
}

public class MainViewController: UIViewController, AddTransactionViewControllerDelegate, TransactionViewControllerDelegate {
    
    var transactionManager: TransactionManager {
        return TransactionManager.shared
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
        guard let addNavigationController = UIStoryboard(name: "Add Transaction", bundle: nil).instantiateInitialViewController() as? UINavigationController, let addViewController = addNavigationController.topViewController as? AddTransactionViewController else { return }
        
        addViewController.delegate = self
        
        present(addNavigationController, animated: true, completion: nil)
    }
    
    func showAddTransactionAlert(description: String?, amount: String?) {
        let alert = UIAlertController(title: "Add Transaction", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { descriptionTextfield in
            descriptionTextfield.placeholder = "Description"
            descriptionTextfield.text = description
        })
        
        alert.addTextField(configurationHandler: { amountTextfield in
            amountTextfield.placeholder = "Amount"
            amountTextfield.keyboardType = .decimalPad
            amountTextfield.text = amount
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            guard let textFields = alert.textFields else { return }
            
            guard let newDescription = textFields[0].text, newDescription.count > 0 else {
                self.alert(title: "Error", message: "Please enter a valid description", completion: {
                    self.present(alert, animated: true, completion: nil)
                })
                return
            }
            
            guard let newAmountString = alert.textFields?[1].text, newAmountString.count > 0, let newAmount = Float(newAmountString) else {
                self.alert(title: "Error", message: "Please enter a valid amount", completion: {
                    self.present(alert, animated: true, completion: nil)
                })
                return
            }
            
            self.transactionManager.addTransaction(withDescription: newDescription, amount: newAmount)
            self.reloadViews()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func reloadBalanceView() {
        balanceView.viewItem = transactionManager.transactions.balanceViewItem
    }
    
    private func reloadTransactionList() {
        transactionViewController.cellItems = transactionManager.transactions.transactionCellItems
        transactionViewController.reloadData()
    }
    
    private func reloadViews() {
        reloadBalanceView()
        reloadTransactionList()
    }
    
    // MARK: Conformance -
    
    // MARK: AddTransactionViewControllerDelegate
    
    func userDidAddTransaction(in viewController: AddTransactionViewController) {
        reloadViews()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidCancel(in viewController: AddTransactionViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TransactionViewControllerDelegate
    
    func userDidDeleteTransaction(at index: Int) {
        let transaction = TransactionManager.shared.transactions[index]
        transactionManager.removeTransaction(transaction)
        
        reloadBalanceView()
    }
}

