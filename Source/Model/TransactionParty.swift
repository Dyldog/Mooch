//
//  TransactionParty.swift
//  FriendTab
//
//  Created by Dylan Elliott on 11/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

enum TransactionParty {
    case me
    case them
    case noOne
    
}

extension TransactionParty: CustomStringConvertible{
    
    var description: String {
        switch self {
        case .me: return "Me"
        case .them: return "Them"
        case .noOne: return "No One"
        }
    }
}

extension TransactionParty {
    var borrowerSign: Sign {
        return [Sign.negative, Sign.positive].first(where: { $0.borrower == self })!
    }
}

extension TransactionParty {
    var moocherColor: UIColor {
        switch self {
        case .me: return UIColor.Moocher.yellow
        case .them: return UIColor.Moocher.red
        case .noOne: return UIColor.Moocher.green
        }
    }
}
