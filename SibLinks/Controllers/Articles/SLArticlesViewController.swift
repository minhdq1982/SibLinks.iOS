//
//  SLArticlesViewController.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLArticlesViewController: SLBaseViewController {
    
    var article: SLArticle?
    static let nibName = "SLArticlesViewController"
    static var controller: SLArticlesViewController! {
        let controller = SLArticlesViewController(nibName: SLArticlesViewController.nibName, bundle: nil)
        return controller
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        parseArticle()
        
        if let articleId = article?.objectId {
            VideoRouter(endpoint: VideoEndpoint.UpdateViewArticle(articleId: articleId)).request(completion: { (result) in
                switch result {
                case .Ok:
                    if let articleValue = self.article?.numViews {
                        self.article?.numViews = articleValue + 1
                        self.tableView.reloadData()
                    }
                default:
                    print("Error")
                }
            })
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update empty state frame equal super view
        loadingView?.frame = self.tableView.frame
        emptyView?.frame = self.tableView.frame
        errorView?.frame = self.tableView.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SLArticlesViewController {
    
    // MARK: - Configure
    
    override func configView() {
        super.configView()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(SLArticleInfoTableViewCell.nib()
            , forCellReuseIdentifier: SLArticleInfoTableViewCell.cellIdentifier())
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ArticleContentViewCellID")
    }
    
    private func parseArticle() {
        if let article = article {
            if let content = article.content {
                let decodeContent = content.ped_decodeURIComponent()
                decodeContent.convertHTML({ (attributedString) in
                    if let attributedString = attributedString {
                        let content = NSMutableAttributedString(attributedString: attributedString)
                        content.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, content.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (value, range, stop) -> Void in
                            if let attachement = value as? NSTextAttachment {
                                if let image = attachement.imageForBounds(attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location) {
                                    let screenSize: CGRect = UIScreen.mainScreen().bounds
                                    if image.size.width > screenSize.width-2 {
                                        let ratio = image.size.height/image.size.width
                                        attachement.bounds = CGRectMake(attachement.bounds.origin.x, attachement.bounds.origin.y, (screenSize.width-16), (screenSize.width-16)*ratio)
                                    }
                                }
                            }
                        }
                        self.loading = false
                        self.endLoading()
                        article.contentParsed = content
                        self.tableView.reloadData()
                    }
                    }, failure: { (error) in
                        self.endLoading()
                })
            } else {
                // Show no content
                self.loading = true
                self.endLoading()
            }
        } else {
            // Show no content
            self.loading = true
            self.endLoading()
        }
    }
}

extension SLArticlesViewController {
    
    // MARK: - Actions
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension SLArticlesViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 0
        }
        
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLArticleInfoTableViewCell.cellIdentifier(), forIndexPath: indexPath)
            
            if let articleCell = cell as? SLArticleInfoTableViewCell {
                articleCell.configCellWithData(article)
                return articleCell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ArticleContentViewCellID", forIndexPath: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = article?.contentParsed
            cell.textLabel?.textAlignment = .Justified
            return cell
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension SLArticlesViewController: UITableViewDelegate {
    
}

extension SLArticlesViewController {
    override func hasContent() -> Bool {
        return !loading
    }
}
