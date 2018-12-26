//
//  SLSearchMentorViewController.swift
//  SibLinks
//
//  Created by Jana on 10/4/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLSearchMentorViewController: SLTopMentorsViewController {
    
    static let searchMentorViewControllerID = "SLSearchMentorViewController"
    
    static var controller: SLSearchMentorViewController! {
        let controller = UIStoryboard(name: "SearchScreen", bundle: nil).instantiateViewControllerWithIdentifier(SLSearchMentorViewController.searchMentorViewControllerID) as! SLSearchMentorViewController
        return controller
    }
    var searchText: String?
    var searchVideo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !searchVideo {
            self.navigationItem.title = "Search".localized
            self.createSearch()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if !searchVideo {
            self.navigationItem.title = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func queryForTable() -> BaseRouter? {
        return MentorRouter(endpoint: MentorEndpoint.GetMentor(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, subjectId: -1, type: MentorType.Subscribe, search: searchText ?? ""))
    }
}

extension SLSearchMentorViewController: UISearchBarDelegate {
    
    // MARK: - Actions
    func createSearch() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = .Minimal
        self.navigationItem.titleView = searchBar
        searchBar.text = self.searchText ?? ""
    }
    
    override func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchText = searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        loadObjects()
        searchBar.resignFirstResponder()
    }
}
