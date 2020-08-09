//
//  String+Extension.swift
//  NearbyRestaurants
//
//  Created by Thanathip Kumnarai on 9/8/2563 BE.
//  Copyright © 2563 xx. All rights reserved.
//

import Foundation

extension String {

    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
