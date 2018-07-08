//
//  UIEdgeInsetsZero Fix.swift
//  FriendTab
//
//  Created by Dylan Elliott on 8/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

#if swift(>=4.2)
import UIKit.UIGeometry
extension UIEdgeInsets {
    public static let zero = UIEdgeInsets()
}
#endif
