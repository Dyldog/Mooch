//
//  TransactionViewController.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

struct TransactionCellItem {
    let description: String
    let amount: Float
    let date: String
}

protocol TransactionViewControllerDelegate {
    func userDidSelectTransaction(at index: Int)
    func userDidDeleteTransaction(at index: Int)
}

@IBDesignable
class TransactionViewController: UITableViewController {
    
    var delegate: TransactionViewControllerDelegate?
    
    var cellItems: [TransactionCellItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TransactionTableViewCell ?? UINib(nibName: "TransactionTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil).first! as! TransactionTableViewCell
        
        let item = cellItems[indexPath.row]
        
        cell.descriptionLabel.text = item.description
        cell.amountView.setAmount(item.amount)
        cell.dateLabel.text = item.date
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        if editingStyle == .delete {
            cellItems.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.userDidDeleteTransaction(at: index)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.userDidSelectTransaction(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}
