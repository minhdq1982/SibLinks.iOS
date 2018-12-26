//
//  SLSearchVideoViewController.swift
//  SibLinks
//
//  Created by Jana on 10/4/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLSearchVideoViewController: SLVideoSubscriberListViewController {

    static let searchVideoViewControllerID = "SLSearchVideoViewController"
    
    static var controller: SLSearchVideoViewController! {
        let controller = UIStoryboard(name: "SearchScreen", bundle: nil).instantiateViewControllerWithIdentifier(SLSearchVideoViewController.searchVideoViewControllerID) as! SLSearchVideoViewController
        return controller
    }
    
    var searchText: String?
    var category: SLCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, forEvent:nil)
        return VideoRouter(endpoint: VideoEndpoint.SearchVideo(subjectId: category?.objectId ?? -1, search: searchText ?? ""))
    }
}
