//
//  SLNumberFormatter.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit

let currencySymbol = SLNumberFormatter.sharedInstance.currencyNumberFormatter.currencySymbol
let currencyCode = SLNumberFormatter.sharedInstance.currencyNumberFormatter.currencyCode

func currencyStringFrom(number: CGFloat? = 0.0) -> String {
    let numberObject = NSNumber(float: Float(number ?? 0.0))
    let currencyString = (SLNumberFormatter.sharedInstance.currencySymbol ?? "$") + "\(numberObject)"

    return currencyString
}

/** SLNumberFormatter Class

 */
class SLNumberFormatter {

    static let sharedInstance = SLNumberFormatter()

    private init(){}

    var currencyCode: String?
    var currencySymbol: String?

    lazy var currencyNumberFormatter: NSNumberFormatter = self.createCurrencyNumberFormatter()
    
    private func createCurrencyNumberFormatter() -> NSNumberFormatter {
        let currencyNumberFormatter = NSNumberFormatter()
        
        currencyNumberFormatter.numberStyle = .CurrencyStyle
        currencyNumberFormatter.maximumFractionDigits = 2
        
        return currencyNumberFormatter
    }
}

extension SLNumberFormatter {

    // MARK: - Currency code

    func setCurrencyCodeWithIdentifier(identifier: String?) {
        guard let identifier = identifier else {
            currencyNumberFormatter.locale = NSLocale.currentLocale()

            return
        }
        currencyNumberFormatter.locale = NSLocale(localeIdentifier: identifier)
    }

    func setCurrencyCode(code: String?) {
        guard let code = code else {
            return
        }

        self.currencyCode = code
    }

    func setCurrencySymbol(symbol: String?) {
        guard let symbol = symbol else {
            return
        }

        self.currencySymbol = symbol
    }
}
