//
//  Transaction.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

enum TransactionParty {
    case me
    case them
    case noOne
}

enum Sign {
    case negative
    case zero
    case positive
}

extension Float {
    var sign: Sign {
        switch self {
        case ..<0.0: return .negative
        case 0.0: return .zero
        default: return .positive
        }
    }
    
    var payer: TransactionParty {
        switch self.sign {
        case .negative: return .them
        case .zero: return .noOne
        case .positive: return .me
        }
    }
    
    var payee: TransactionParty {
        switch payer {
        case .me: return .them
        case .them: return .me
        case .noOne: return .noOne
        }
    }
}

struct Transaction_v1 {
    let id: String
    let amount: Float
    let description: String
}

class Person_v1: NSObject {
    let id: String
    let name: (String, String)
    var transactions: [Transaction]
    
    init(id: String, name: (String, String), transactions: [Transaction]) {
        self.id = id
        self.name = name
        self.transactions = transactions
    }
}
