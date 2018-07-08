//
//  BalanceViewController.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

struct BalanceViewItem {
    let balance: String
    let liableParty: String
    let remainingTransactions: String
}

@IBDesignable
class BalanceView: NibDesignable {
    
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var liablePartyLabel: UILabel!
    @IBOutlet var remainingTransactionsLabel: UILabel!
    
    var viewItem: BalanceViewItem! {
        didSet {
            amountLabel.text = viewItem.balance
            liablePartyLabel.text = viewItem.liableParty
            remainingTransactionsLabel.text = viewItem.remainingTransactions
        }
    }
}
