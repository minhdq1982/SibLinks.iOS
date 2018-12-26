//
//  SLMoreMentorsViewController.swift
//  SibLinks
//
//  Created by Jana on 10/20/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMoreMentorsViewController: SLTopMentorsViewController {
    
    var query: BaseRouter?
    var navigationTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = navigationTitle
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        return query
    }
}
