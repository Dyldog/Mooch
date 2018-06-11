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

@IBDesignable
class TransactionViewController: TextTableViewController {
    
    var cellItems: [TransactionCellItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
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
}
