//
//  AddTransactionViewController.swift
//  FriendTab
//
//  Created by Dylan Elliott on 7/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import CoreData
import Eureka

enum AmountError: Error {
    case incorrectArgumentCount
}

struct Amount: Codable, Equatable {
    
    var type: AmountType
    var inputs: [Float]
    
    var value: Float {
        return try! Amount.calculateValue(ofType: type, with: inputs)
    }
    
    static func calculateValue(ofType type: AmountType, with inputs: [Float]) throws -> Float {
        let tupleValue = (inputs[0], inputs.count >= 2 ? inputs[1] : nil, inputs.count >= 3 ? inputs[2] : nil)
        
        switch (type, tupleValue) {
        case (.simple, (let simpleValue, nil, nil)):
            return simpleValue
        case (.percentage, (let fullAmount, .some(let percentage), nil)):
            return percentage / 100.0 * fullAmount
        case (.ratio, (let fullAmount, .some(let ratioX), .some(let ratioY))):
            return ratioX / ratioY * fullAmount
        default:
            throw AmountError.incorrectArgumentCount
        }
    }
}

enum AmountType: Int, Codable {
    case simple
    case percentage
    case ratio
    
    var shortDescription: String {
        switch self {
        case .simple: return "123"
        case .percentage: return "%"
        case .ratio: return "x/y"
        }
    }
}

extension Double {
    var floatValue: Float {
        return Float(self)
    }
}

extension Int {
    var floatValue: Float {
        return Float(self)
    }
}

protocol AddTransactionViewControllerDelegate {
    func userDidAddTransaction(in viewController: AddTransactionFormViewController)
    func userDidUpdateTransaction(in viewController: AddTransactionFormViewController)
    func userDidCancel(in viewController: AddTransactionFormViewController)
}

class AddTransactionFormViewController: FormViewController {
    
    var personId: NSManagedObjectID? {
        didSet {
            loadViewIfNeeded()
            loadForm()
        }
    }
    
    var person: Person? {
        guard let personId = personId else { return nil }
        return TransactionManager.shared.person(withId: personId)
    }
    
    var transactionId: NSManagedObjectID? {
        didSet {
            loadViewIfNeeded()
            loadForm()
        }
    }
    
    var transaction: Transaction? {
        guard let transactionId = transactionId else { return nil }
        return TransactionManager.shared.transaction(withId: transactionId)
    }
    
    var delegate: AddTransactionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
    }
    
    func loadForm() {
        form.removeAll()
        
        guard let person = person else { return }
        
        func updateTints() {
            let segmentedRow: SegmentedRow<TransactionParty> = form.rowBy(tag: "moocher")!
            let color = segmentedRow.value!.moocherColor
            
            form.allRows.forEach({ $0.baseCell.tintColor = color })
//            form.rowBy(tag: "clearSettlementButton")?.baseCell.tintColor = UIColor.Moocher.red
            
            navigationItem.leftBarButtonItem!.tintColor = color
        }
        
        form +++ Section()
            <<< SegmentedRow<TransactionParty>("moocher", { segmentedRow in
                segmentedRow.title = "Moocher"
                segmentedRow.options = [.me, .them]
                segmentedRow.value = transaction?.amount.value.sign.borrower ?? .me
                
                segmentedRow.cellSetup { cell, row in
                    cell.segmentedControl.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
                    updateTints()
                }
                
                segmentedRow.onChange({ segmentedRow in
                    updateTints()
                })
                
            })
            <<< TextRow("description", { descriptionRow in
                descriptionRow.title = "Description"
                descriptionRow.value = transaction?.transactionDescription
            })
            <<< DateTimeRow("date", { dateRow in
                dateRow.title = "Date"
                dateRow.value = transaction?.date ?? Date()
            })
                
        form +++ Section("Amount")
            <<< SegmentedRow<AmountType>("amountType") { amountTypeRow in
                amountTypeRow.options = [.simple, .percentage, .ratio]
                amountTypeRow.value = .simple
                amountTypeRow.displayValueFor = { $0?.shortDescription }
                amountTypeRow.onChange { _ in self.updateAmountRows() }
            }
            
            <<< DecimalRow("amount", { amountRow in
                amountRow.title = "(Full) Amount"
                amountRow.formatter = {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    return formatter
                }()
                
                amountRow.value = transaction != nil ? Double(abs(transaction!.amount.value)) : nil
                
                amountRow.onChange { _ in self.updateTotalRow() }
            })
            
            
            <<< IntRow("amountVar1", { row in
                row.onChange { _ in self.updateTotalRow() }
            })
            
            <<< IntRow("amountVar2", { row in
                row.onChange { _ in self.updateTotalRow() }
            })
            
            <<< TextRow("totalAmount", { totalAmount in
                totalAmount.title = "Your Share"
                totalAmount.value = "?"
                totalAmount.disabled = Condition(booleanLiteral: true)
//                totalAmount.hidden = Condition.function(["amountType"], { form in
//                    return (form.rowBy(tag: "amountType") as? SegmentedRow<AmountType>)?.value! == .simple
//                })
            })
        
        form +++ Section("Payback")
            <<< DateTimeRow("settlementDate", { dateRow in
                dateRow.title = "Date"
                dateRow.value = transaction?.settlementDate
                dateRow.onCellSelection { cell, row in
                    row.value = Date()
                    row.updateCell()
                }
            })
            <<< ButtonRow("clearSettlementButton", { clearSettlementButton in
                clearSettlementButton.title = "Clear"
                clearSettlementButton.cellSetup { cell, row in
                    cell.textLabel?.tintColor = .red
                }
                clearSettlementButton.onCellSelection { cell, row in
                    let settlementDateRow = self.form.rowBy(tag: "settlementDate")!
                    settlementDateRow.baseValue = nil
                    settlementDateRow.updateCell()
                }
            })
        
        form +++ Section()
            <<< ButtonRow("button", { button in
                button.title = transaction == nil ? "Add" : "Save"
                button.cellSetup({ _,_ in updateTints() })
                button.onCellSelection({ _, _ in
                    let amountRow: DecimalRow = self.form.rowBy(tag: "amount")!
                    let descriptionRow: TextRow = self.form.rowBy(tag: "description")!
                    let moocherRow: SegmentedRow<TransactionParty> = self.form.rowBy(tag: "moocher")!
                    let dateRow: DateTimeRow = self.form.rowBy(tag: "date")!
                    let settlementDateRow: DateTimeRow = self.form.rowBy(tag: "settlementDate")!
                    
                    let moocher = moocherRow.value!
                    let date = dateRow.value!
                    let settlementDate = settlementDateRow.value
                    
                    guard let description = descriptionRow.value, description.count > 0 else {
                        self.alert(title: "Error", message: "Please enter a description", completion: nil); return
                    }
                    
                    guard let amountValue = self.totalAmountValue else {
                        self.alert(title: "Error", message: "Please enter an amount", completion: nil); return
                    }
                    
                    let unsignedAmount = Float(amountValue)
                    
                    let sign = moocher.borrowerSign
                    let amount = Float(sign.rawValue) * unsignedAmount
                    
                    if let transaction = self.transaction {
                        TransactionManager.shared.updateTransaction(transaction, withDescription: description, amount: amount, date: date, settlementDate: settlementDate)
                        self.delegate?.userDidUpdateTransaction(in: self)
                    } else {
                        TransactionManager.shared.addTransaction(withDescription: description, amount: amount, date: date, settlementDate: settlementDate, forPersonWithId: person.objectID)
                        self.delegate?.userDidAddTransaction(in: self)
                    }
                })
            })
        
        updateAmountRows()
    }
    
    var totalAmountValue: Double? {
        let selectedType = (form.rowBy(tag: "amountType") as? SegmentedRow<AmountType>)!.value!
        
        let amountRow = form.rowBy(tag: "amount") as! DecimalRow
        let var1Row = form.rowBy(tag: "amountVar1") as! IntRow
        let var2Row = form.rowBy(tag: "amountVar2") as! IntRow
        
        
        let inputs = ([amountRow.value?.floatValue ?? 0.0,
                       [AmountType.percentage, AmountType.ratio].contains(selectedType) ? var1Row.value?.floatValue : nil,
                       [AmountType.ratio].contains(selectedType) ? var2Row.value?.floatValue : nil
            ]) .compactMap({ $0 })
        
        if let totalValue = try? Amount.calculateValue(ofType: selectedType, with: inputs) {
            return Double(totalValue)
        } else {
            return nil
        }
    }
    
    func updateAmountRows() {
        let selectedType = (form.rowBy(tag: "amountType") as! SegmentedRow<AmountType>).value!
        
        let amountRow = form.rowBy(tag: "amount") as! DecimalRow
        let var1Row = form.rowBy(tag: "amountVar1") as! IntRow
        let var2Row = form.rowBy(tag: "amountVar2") as! IntRow
        let totalRow = form.rowBy(tag: "totalAmount") as! TextRow
        
        func updateRowStates(var1Hidden: Bool, var2Hidden: Bool) {
            var1Row.hidden = Condition(booleanLiteral: var1Hidden)
            var1Row.evaluateHidden()
            
            var2Row.hidden = Condition(booleanLiteral: var2Hidden)
            var2Row.evaluateHidden()
            
            totalRow.hidden = Condition(booleanLiteral: var1Hidden && var2Hidden)
            totalRow.evaluateHidden()
            
            amountRow.title = totalRow.isHidden == true ? "Amount" : "Full Amount"
            amountRow.updateCell()
        }
        
        switch selectedType {
        case .simple:
            updateRowStates(var1Hidden: true, var2Hidden: true)
        case .percentage:
            var1Row.title = "Percentage"
            var1Row.updateCell()
            updateRowStates(var1Hidden: false, var2Hidden: true)
        case .ratio:
            var1Row.title = "X"
            var1Row.updateCell()
            var2Row.title = "Y"
            var2Row.updateCell()
            updateRowStates(var1Hidden: false, var2Hidden: false)
        }
        
        if selectedType != .simple { updateTotalRow() }
    }
    
    func updateTotalRow() {
        let moocher = (form.rowBy(tag: "moocher") as! SegmentedRow<TransactionParty>).value!
        let totalRow = (form.rowBy(tag: "totalAmount") as? TextRow)!
        
        totalRow.title = moocher == .me ? "Their Share" : "My Share"
        totalRow.value = "?"
        if let total = totalAmountValue {
            totalRow.value = NumberFormatter.sharedCurrencyFormatter.string(from: NSNumber(value: total))
        }
        
        totalRow.updateCell()
    }
    
    @objc func cancelButtonTapped() {
        delegate?.userDidCancel(in: self)
    }
}

//class AddTransactionViewController: UIViewController, UITextFieldDelegate {
//    
//    var personId: NSManagedObjectID? {
//        didSet { upadateNameViews() }
//    }
//    
//    var person: Person? {
//        guard let personId = personId else { return nil }
//        return TransactionManager.shared.person(withId: personId)
//    }
//    
//    private enum BorrowerSegmentedControlIndices: Int {
//        case me = 0
//        case them
//        
//        var transactionSign: Int {
//            switch self {
//            case .me: return -1
//            case .them: return 1
//            }
//        }
//    }
//    
//    @IBOutlet private var descriptionTextField: UITextField!
//    
//    @IBOutlet private var fromLabel: UILabel! {
//        didSet { upadateNameViews() }
//    }
//    
//    @IBOutlet private var amountTextField: UITextField! {
//        didSet {
//            amountTextField.delegate = self
//        }
//    }
//    @IBOutlet private var payeeSegementedControl: UISegmentedControl! {
//        didSet { upadateNameViews() }
//    }
//    
//    private var selectedDate = Date() {
//        didSet { updateDateButton() }
//    }
//    
//    @IBOutlet private var dateButton: UIButton! {
//        didSet { updateDateButton() }
//    }
//    
//    var delegate: AddTransactionViewControllerDelegate?
//    
//    @IBAction func cancelButtonTapped() {
////        delegate?.userDidCancel(in: self)
//    }
//    
//    @IBAction func addButtonTapped() {
//        addTransaction()
//    }
//    
//    @IBAction func dateButtonTapped() {
//        descriptionTextField.resignFirstResponder()
//        amountTextField.resignFirstResponder()
//        showDatePicker { date in self.selectedDate = date }
//    }
//    
//    @IBAction func selectedPayeeDidChange() {
//        updateFromLabel()
//    }
//    
//    private func showDatePicker(completion: @escaping (Date) -> Void) {
//        let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
//        alert.addDatePicker(mode: .dateAndTime, date: selectedDate, minimumDate: nil, maximumDate: Date()) { date in
//            completion(date)
//        }
//        
//        alert.addAction(title: "OK", style: .cancel)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    private func updateDateButton() {
//        dateButton.setTitle(DateFormatter.sharedDateFormatter.string(from: selectedDate), for: .normal)
//    }
//    
//    private func updateFromLabel() {
//        guard let payeeSegementedControl = payeeSegementedControl, let fromLabel = fromLabel else { return }
//        let fromName: String = {
//            switch BorrowerSegmentedControlIndices(rawValue: payeeSegementedControl.selectedSegmentIndex)! {
//            case .me: return "Sarah"
//            case .them: return "Me"
//            }
//        }()
//        
//        fromLabel.text = "from \(fromName) for"
//    }
//    
//    private func upadateNameViews() {
//        guard let firstName = person?.firstName else { return }
//        
//        if let payeeSegementedControl = payeeSegementedControl {
//            payeeSegementedControl.segmentTitles[1] = firstName
//            payeeSegementedControl.selectedSegmentIndex = 0
//        }
//        
//        updateFromLabel()
//    }
//    
//    private func addTransaction() {
//        guard let person = person else { return }
//        
//        guard let description = descriptionTextField.text, description.count > 0 else {
//            alert(title: "Error", message: "Please enter a description", completion: nil); return
//        }
//        
//        guard let amountString = amountTextField.text else {
//            alert(title: "Error", message: "Please enter an amount", completion: nil); return
//        }
//        
//        guard let unsignedAmount = Float(amountString.dropFirst(1)) else {
//            alert(title: "Error", message: "Please enter a valid amount", completion: nil); return
//        }
//        
//        let sign = Float(BorrowerSegmentedControlIndices(rawValue: payeeSegementedControl.selectedSegmentIndex)!.transactionSign)
//        let amount = sign * unsignedAmount
//        
//        TransactionManager.shared.addTransaction(withDescription: description, amount: amount, date: selectedDate, forPersonWithId: person.objectID)
//        
////        delegate?.userDidAddTransaction(in: self)
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        guard let text = textField.text, let textRange = Range(range, in: text) else { return false }
//        let updatedText = text.replacingCharacters(in: textRange, with: string)
//        
//        if let dollarIdx = updatedText.lastIndex(of: "$"), dollarIdx.encodedOffset > 0 { return false }
//        
//        let strippedNumberString = updatedText.replacingOccurrences(of: "$", with: "")
//        
//        guard strippedNumberString.count > 0 else {
//            textField.text = ""
//            return false
//        }
//        
//        guard let _ = Float(strippedNumberString) else { return false }
//        
//        if !updatedText.contains("$") {
//            textField.text = "$\(strippedNumberString)"
//            return false
//        } else {
//            return true
//        }
//    }
//}
