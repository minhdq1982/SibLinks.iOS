//
//  SLVideoHomeViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoHomeViewController: SLVideoListViewController {
    
    override func queryForTable() -> VideoRouter {
        // Subclass override method to query database
        return VideoRouter(endpoint: .GetVideos(subjectId: (category?.objectId ?? -1)))
    }
    
}
