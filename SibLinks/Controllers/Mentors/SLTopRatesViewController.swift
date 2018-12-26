//
//  SLTopRatesViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLTopRatesViewController: SLTopMentorsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func queryForTable() -> BaseRouter? {
        // Subclass override method to query database
        
        return MentorRouter(endpoint: MentorEndpoint.GetMentor(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, subjectId: (category?.objectId ?? -1), type: MentorType.Rate, search: ""))
    }
}
