//
//  AmountView.swift
//  FriendTab
//
//  Created by Dylan Elliott on 8/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

class AmountView: UIView {
    @IBOutlet private var label: UILabel!
    
    func setAmount(_ amount: Float) {
        label.text = NumberFormatter.sharedCurrencyFormatter.string(from: abs(amount) as NSNumber)
        
        switch amount.payer {
        case .me: backgroundColor = .red
        case .noOne: backgroundColor = .green
        case .them: backgroundColor = .yellow
        }
    }
}
