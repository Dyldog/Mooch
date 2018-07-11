//
//  Sign.swift
//  FriendTab
//
//  Created by Dylan Elliott on 11/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

enum Sign: Int {
    case negative = -1
    case zero = 0
    case positive = 1
    
    var borrower: TransactionParty {
        switch self {
        case .negative: return .me
        case .zero: return .noOne
        case .positive: return .them
        }
    }
    
    var lender: TransactionParty {
        switch borrower {
        case .me: return .them
        case .them: return .me
        case .noOne: return .noOne
        }
    }
}

extension Float {
    var sign: Sign {
        switch self {
        case ..<0.0: return .negative
        case 0.0: return .zero
        default: return .positive
        }
    }
}
