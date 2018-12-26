//
//  String+HTML.swift
//  Home
//
//  Created by Anh Nguyen on 10/6/16.
//  Copyright © 2016 Skypiea. All rights reserved.
//

import Foundation
import UIKit

extension String {
    // MARK: - HTML
    func convertHTML(success: ((NSAttributedString?) -> ())?, failure: ((NSError?) -> Void)?) {
        convertHTML("Lato-Regular", fontSize: 15, success: success, failure: failure)
    }
    
    func convertHTML(fontName: String, fontSize: CGFloat, success: ((NSAttributedString?) -> ())?, failure: ((NSError?) -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            var attributedString = NSMutableAttributedString()
            let string = self.stringByAppendingString("<style>body{font-family: \(fontName); font-size:\(fontSize)px;}</style>")
            if let data = string.dataUsingEncoding(NSUnicodeStringEncoding) {
                do {// allowLossyConversion: true
                    attributedString = try NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        success?(attributedString)
                    })
                }
                catch {
                    print("error creating attributed string")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        failure?(nil)
                    })
                }
            }
            
        })
        
    }
}
