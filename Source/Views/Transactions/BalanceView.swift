//
//  BalanceViewController.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

struct BalanceViewItem {
    let balance: Float
    let liableParty: String
    let remainingTransactions: String
}

@IBDesignable
class BalanceView: NibDesignable {
    
    @IBOutlet var amountView: AmountView!
    @IBOutlet var liablePartyLabel: UILabel!
    @IBOutlet var remainingTransactionsLabel: UILabel!
    
    var viewItem: BalanceViewItem! {
        didSet {
            amountView.setAmount(viewItem.balance)
            liablePartyLabel.text = viewItem.liableParty
            remainingTransactionsLabel.text = viewItem.remainingTransactions
        }
    }
}
