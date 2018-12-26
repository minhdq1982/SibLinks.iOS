//
//  SLReplaceSegue.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLReplaceSegue: UIStoryboardSegue {
    override func perform() {
        UIView.transitionWithView(Constants.appDelegate().window!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            let oldState: Bool = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            Constants.appDelegate().window?.rootViewController = self.destinationViewController
            UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                
        })
    }
}
