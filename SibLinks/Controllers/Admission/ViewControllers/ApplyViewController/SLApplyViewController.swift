//
//  SLApplyViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

enum TutorialType: Int {
    case Video = 0
    case Article = 1
}

class SLApplyViewController: SLBaseTableViewController {
    var videos = [SLVideo]()
    var articles = [SLArticle]()
    var admissionId: Int {
        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadObjects()
    }
}

extension SLApplyViewController {
    
    // MARK: - Configure
    override func configView() {
        super.configView()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(SLMentorProfileVideosTableViewCell.nib(), forCellReuseIdentifier: SLMentorProfileVideosTableViewCell.cellIdentifier())
        self.tableView.separatorStyle = .None
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(_:)), forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
    }
    
    func loadObjects() {
        loading = true
        startLoading(false, completion: nil)
        
        var hasError = false
        let requestGroup = dispatch_group_create()
        // Get videos
        dispatch_group_enter(requestGroup)
        EssayRouter(endpoint: EssayEndpoint.GetTutorialVideos(admissonId: admissionId)).request { (result) in
            switch result {
            case .Success(let objects):
                if let videos = objects as? [SLVideo] {
                    self.videos = videos
                }
                break
            default:
                hasError = true
                break
            }
            dispatch_group_leave(requestGroup)
        }
        
        // Get ariticles
        dispatch_group_enter(requestGroup)
        EssayRouter(endpoint: EssayEndpoint.GetArticles(admissonId: admissionId)).request { (result) in
            switch result {
            case .Success(let objects):
                if let articles = objects as? [SLArticle] {
                    self.articles = articles
                }
                break
            default:
                hasError = true
                break
            }
            dispatch_group_leave(requestGroup)
        }
        
        dispatch_group_notify(requestGroup, dispatch_get_main_queue()) {
            self.loading = false
            self.endLoading(false, error: hasError ? Constants.NetworkError : nil, completion: nil)
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func refreshControlValueChanged(refreshControl: UIRefreshControl) {
        if !loading {
            loadObjects()
        }
    }
}

extension SLApplyViewController {
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (videos.count < 1 && articles.count < 1) {
            return 0
        } else if (videos.count < 1 && articles.count > 0) {
            return 1
        } else if (videos.count > 0 && articles.count < 1) {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLMentorProfileVideosTableViewCell.cellIdentifier())
        
        if let myEssayCell = cell as? SLMentorProfileVideosTableViewCell {
            myEssayCell.mentorDelegate = self
            myEssayCell.setIndexPath(indexPath, sender: self)
            switch indexPath.row {
            case TutorialType.Video.rawValue:
                myEssayCell.headerLabel.text = "Video Tutorials"
                myEssayCell.configCellWithData(self.videos)
                myEssayCell.moreButton.hidden = true
            case TutorialType.Article.rawValue:
                myEssayCell.headerLabel.text = "Articles"
                myEssayCell.configCellWithData(self.articles)
                myEssayCell.moreButton.hidden = true
            default:
                break
            }
            
            return myEssayCell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}

extension SLApplyViewController {
    override func hasContent() -> Bool {
        if videos.count > 0 || articles.count > 0 {
            return true
        } else {
            return !loading
        }
    }
}

extension SLApplyViewController: MentorTutorialViewDelegate {
    
    // MARK: - MentorTutorialViewDelegate
    
    func showVideo(video: SLVideo) {
        let detailViewController = SLVideoDetailViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
        detailViewController.admission = true
        detailViewController.admissionId = admissionId
        detailViewController.video = video
        self.presentViewController(detailViewController, animated: true, completion: nil)
    }
    
    func showArticle(article: SLArticle) {
        let viewController = SLArticlesViewController.controller
        viewController.article = article
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func showMore(indexPath: NSIndexPath?) {
        if let indexPath = indexPath {
            switch indexPath.row {
            case TutorialType.Video.rawValue:
                let moreVideos = SLMoreVideosViewController()
                moreVideos.navigationTitle = "Video Tutorials"
                moreVideos.query = EssayRouter(endpoint: EssayEndpoint.GetTutorialVideos(admissonId: admissionId))
                self.navigationController?.pushViewController(moreVideos, animated: true)
            case TutorialType.Article.rawValue:
                let moreArticles = SLMoreArticlesViewController()
                moreArticles.navigationTitle = "Articles"
                moreArticles.query = EssayRouter(endpoint: EssayEndpoint.GetArticles(admissonId: admissionId))
                self.navigationController?.pushViewController(moreArticles, animated: true)
            default:
                break
            }
        }
    }
}
