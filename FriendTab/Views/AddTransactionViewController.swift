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

class AddTransactionViewController: UIViewController, UITextFieldDelegate {
    
    var personId: String? {
        didSet {
            title = person?.name.0
        }
    }
    
    var person: Person? {
        return TransactionManager.shared.people.first(where: { $0.id == personId })
    }
    
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
    @IBOutlet private var amountTextField: UITextField! {
        didSet {
            amountTextField.delegate = self
        }
    }
    @IBOutlet private var payeeSegementedControl: UISegmentedControl!
    
    var delegate: AddTransactionViewControllerDelegate?
    
    @IBAction func cancelButtonTapped() {
        delegate?.userDidCancel(in: self)
    }
    
    @IBAction func addButtonTapped() {
        addTransaction()
    }
    
    private func addTransaction() {
        guard let person = person else { return }
        
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
        
        TransactionManager.shared.addTransaction(withDescription: description, amount: amount, forPersonWithId: person.id)
        
        delegate?.userDidAddTransaction(in: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else { return false }
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        guard let _ = Float(updatedText) else { return false }
                
        return true
            
            
            
    }
}
