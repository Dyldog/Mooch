//
//  AddTransactionViewController.swift
//  FriendTab
//
//  Created by Dylan Elliott on 7/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import CoreData

protocol AddTransactionViewControllerDelegate {
    func userDidAddTransaction(in viewController: AddTransactionViewController)
    func userDidCancel(in viewController: AddTransactionViewController)
}

class AddTransactionViewController: UIViewController, UITextFieldDelegate {
    
    var personId: NSManagedObjectID? {
        didSet { upadateNameViews() }
    }
    
    var person: Person? {
        guard let personId = personId else { return nil }
        return TransactionManager.shared.person(withId: personId)
    }
    
    private enum BorrowerSegmentedControlIndices: Int {
        case me = 0
        case them
        
        var transactionSign: Int {
            switch self {
            case .me: return -1
            case .them: return 1
            }
        }
    }
    
    @IBOutlet private var descriptionTextField: UITextField!
    
    @IBOutlet private var fromLabel: UILabel! {
        didSet { upadateNameViews() }
    }
    
    @IBOutlet private var amountTextField: UITextField! {
        didSet {
            amountTextField.delegate = self
        }
    }
    @IBOutlet private var payeeSegementedControl: UISegmentedControl! {
        didSet { upadateNameViews() }
    }
    
    private var selectedDate = Date() {
        didSet { updateDateButton() }
    }
    
    @IBOutlet private var dateButton: UIButton! {
        didSet { updateDateButton() }
    }
    
    var delegate: AddTransactionViewControllerDelegate?
    
    @IBAction func cancelButtonTapped() {
        delegate?.userDidCancel(in: self)
    }
    
    @IBAction func addButtonTapped() {
        addTransaction()
    }
    
    @IBAction func dateButtonTapped() {
        descriptionTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        showDatePicker { date in self.selectedDate = date }
    }
    
    @IBAction func selectedPayeeDidChange() {
        updateFromLabel()
    }
    
    private func showDatePicker(completion: @escaping (Date) -> Void) {
        let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: nil, maximumDate: Date()) { date in
            completion(date)
        }
        
        alert.addAction(title: "OK", style: .cancel)
        present(alert, animated: true, completion: nil)
    }
    
    private func updateDateButton() {
        dateButton.setTitle(DateFormatter.sharedDateFormatter.string(from: selectedDate), for: .normal)
    }
    
    private func updateFromLabel() {
        guard let payeeSegementedControl = payeeSegementedControl, let fromLabel = fromLabel else { return }
        let fromName: String = {
            switch BorrowerSegmentedControlIndices(rawValue: payeeSegementedControl.selectedSegmentIndex)! {
            case .me: return "Sarah"
            case .them: return "Me"
            }
        }()
        
        fromLabel.text = "from \(fromName) for"
    }
    
    private func upadateNameViews() {
        guard let firstName = person?.firstName else { return }
        
        if let payeeSegementedControl = payeeSegementedControl {
            payeeSegementedControl.segmentTitles[1] = firstName
            payeeSegementedControl.selectedSegmentIndex = 0
        }
        
        updateFromLabel()
    }
    
    private func addTransaction() {
        guard let person = person else { return }
        
        guard let description = descriptionTextField.text, description.count > 0 else {
            alert(title: "Error", message: "Please enter a description", completion: nil); return
        }
        
        guard let amountString = amountTextField.text else {
            alert(title: "Error", message: "Please enter an amount", completion: nil); return
        }
        
        guard let unsignedAmount = Float(amountString.dropFirst(1)) else {
            alert(title: "Error", message: "Please enter a valid amount", completion: nil); return
        }
        
        let sign = Float(BorrowerSegmentedControlIndices(rawValue: payeeSegementedControl.selectedSegmentIndex)!.transactionSign)
        let amount = sign * unsignedAmount
        
        TransactionManager.shared.addTransaction(withDescription: description, amount: amount, forPersonWithId: person.objectID)
        
        delegate?.userDidAddTransaction(in: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text, let textRange = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        if let dollarIdx = updatedText.lastIndex(of: "$"), dollarIdx.encodedOffset > 0 { return false }
        
        let strippedNumberString = updatedText.replacingOccurrences(of: "$", with: "")
        
        guard strippedNumberString.count > 0 else {
            textField.text = ""
            return false
        }
        
        guard let _ = Float(strippedNumberString) else { return false }
        
        if !updatedText.contains("$") {
            textField.text = "$\(strippedNumberString)"
            return false
        } else {
            return true
        }
    }
}
