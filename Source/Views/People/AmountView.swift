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
        
        switch amount.sign.lender {
        case .them: backgroundColor = UIColor(hex: "#FFCC00")! // yellow
        case .noOne: backgroundColor = UIColor(hex: "#4CD964")! // green
        case .me: backgroundColor = UIColor(hex: "#FF3B30")! // red
        }
    }
}
