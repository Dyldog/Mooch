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
    let amount: String
}

protocol TransactionViewControllerDelegate {
    func userDidDeleteTransaction(at index: Int)
}

@IBDesignable
class TransactionViewController: TextTableViewController {
    
    var delegate: TransactionViewControllerDelegate?
    
    var cellItems: [TransactionCellItem] = []
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems.count
    }
    override func tableView(_ tableView: UITableView, textForRowAt indexPath: IndexPath) -> String {
        let item = cellItems[indexPath.row]
        return "\(item.amount)"
    }
    
    override func tableView(_ tableView: UITableView, detailTextForRowAt indexPath: IndexPath) -> String? {
        let item = cellItems[indexPath.row]
        return "\(item.description)"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        if editingStyle == .delete {
            cellItems.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.userDidDeleteTransaction(at: index)
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}
