//
//  SLSearchPlaylistViewController.swift
//  SibLinks
//
//  Created by Jana on 10/4/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLSearchPlaylistViewController: SLVideoSubscriberPlayListViewController {

    static let searchPlaylistViewControllerID = "SLSearchPlaylistViewController"
    
    static var controller: SLSearchPlaylistViewController! {
        let controller = UIStoryboard(name: "SearchScreen", bundle: nil).instantiateViewControllerWithIdentifier(SLSearchPlaylistViewController.searchPlaylistViewControllerID) as! SLSearchPlaylistViewController
        return controller
    }
    
    var searchText: String?
    var category: SLCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (self.emptyView as? SLEmptyView)?.errorTitleLabel.text = "Found no playlist."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func queryForTable() -> BaseRouter? {
        return VideoRouter(endpoint: VideoEndpoint.SearchPlaylist(subjectId: category?.objectId ?? -1, search: searchText ?? ""))
    }
}
