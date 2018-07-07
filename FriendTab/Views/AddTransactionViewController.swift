//
//  AddTransactionViewController.swift
//  FriendTab
//
//  Created by Dylan Elliott on 7/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

protocol AddTransactionViewControllerDelegate {
    func userDidAddTransaction(in viewController: AddTransactionViewController)
    func userDidCancel(in viewController: AddTransactionViewController)
}

class AddTransactionViewController: UIViewController {
    
    private enum OwerSegmentedControlIndices: Int {
        case iOwe = 0
        case theyOwe
        
        var transactionSign: Int {
            switch self {
            case .iOwe: return -1
            case .theyOwe: return 1
            }
        }
    }
    
    @IBOutlet private var descriptionTextField: UITextField!
    @IBOutlet private var amountTextField: UITextField!
    @IBOutlet private var payeeSegementedControl: UISegmentedControl!
    
    var delegate: AddTransactionViewControllerDelegate?
    
    @IBAction func cancelButtonTapped() {
        delegate?.userDidCancel(in: self)
    }
    
    @IBAction func addButtonTapped() {
        addTransaction()
    }
    
    private func addTransaction() {
        guard let description = descriptionTextField.text, description.count > 0 else {
            alert(title: "Error", message: "Please enter a description", completion: nil); return
        }
        
        guard let amountString = amountTextField.text else {
            alert(title: "Error", message: "Please enter an amount", completion: nil); return
        }
        
        guard let unsignedAmount = Float(amountString) else {
            alert(title: "Error", message: "Please enter a valid amount", completion: nil); return
        }
        
        let sign = Float(OwerSegmentedControlIndices(rawValue: payeeSegementedControl.selectedSegmentIndex)!.transactionSign)
        let amount = sign * unsignedAmount
        
        TransactionManager.shared.addTransaction(withDescription: description, amount: amount)
        
        delegate?.userDidAddTransaction(in: self)
    }
}
