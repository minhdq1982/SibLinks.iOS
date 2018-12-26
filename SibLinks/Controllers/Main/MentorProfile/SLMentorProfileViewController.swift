//
//  SLMentorProfileViewController.swift
//  SibLinks
//
//  Created by Jana on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable
import Kingfisher

enum MentorProfile: Int {
    case Info = 0
    case Answer = 1
}

enum MentorInfoSection: Int {
    case Detail = 0
    case Info = 1
    case Video = 2
}

class SLMentorProfileViewController: SLBaseViewController {
    
    static let mentorProfileViewControllerID = "SLMentorProfileViewControllerID"
    static var controller: SLMentorProfileViewController! {
        let controller = UIStoryboard(name: Constants.MENTOR_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SLMentorProfileViewController.mentorProfileViewControllerID) as! SLMentorProfileViewController
        return controller
    }

    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var tableView: UITableView!
    var mentor: SLMentor?
    private var videos = [SLVideo]()
    private var answers = [SLAnswer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getMentorProfile()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkSubscriber), name: Constants.SUBSCRIBER_CHANGE, object: nil)
        avatarImageView.kf_indicatorType = .Activity
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Mentor Profile".localized
        
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMentorProfile() {
        if let mentor = mentor {
            if let imagePath = mentor.profileImageName {
                avatarImageView.kf_setImageWithURL(NSURL(string: imagePath), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = nil
            }
            
            var hasError = false
            loading = true
            startLoading(false, completion: nil)
            let requestGroup = dispatch_group_create()
            // Get mentor profile
            if let mentorId = mentor.objectId {
                dispatch_group_enter(requestGroup)
                UserRouter(endpoint: UserEndpoint.GetUserProfile(userId: mentorId, type: UserType.Mentor)).request(completion: { (result) in
                    switch result {
                    case .Success(let objects):
                        dispatch_group_leave(requestGroup)
                        self.mentor = objects as? SLMentor
                        if let categoriesId = mentor.categoriesId {
                            let categoriesId = categoriesId.componentsSeparatedByString(",")
                            var categoriesOfMentor = [SLCategory]()
                            for categoryId in categoriesId {
                                for category in Constants.appDelegate().categories {
                                    if category.objectId == Int(categoryId) {
                                        categoriesOfMentor.append(category)
                                    }
                                }
                            }
                            self.mentor?.categories = categoriesOfMentor
                        }
                    default:
                        print("error")
                        hasError = true
                        dispatch_group_leave(requestGroup)
                    }
                })
            }
            
            // Get video of mentor
            dispatch_group_enter(requestGroup)
            VideoRouter(endpoint: VideoEndpoint.GetVideoOfMentor(mentorId: mentor.objectId!)).request(completion: { (result) in
                switch result {
                case .Success(let objects):
                    if let videos = objects as? [SLVideo] {
                        self.videos = videos
                        for video in self.videos {
                            video.mentor = self.mentor
                        }
                    }
                    dispatch_group_leave(requestGroup)
                    break
                default:
                    dispatch_group_leave(requestGroup)
                    break
                }
            })
            
            // Get aswer of mentor
            if let mentorId = mentor.objectId {
                dispatch_group_enter(requestGroup)
                MentorRouter(endpoint: MentorEndpoint.GetAnswers(mentorId: mentorId)).request(completion: { (result) in
                    switch result {
                    case .Success(let objects):
                        dispatch_group_leave(requestGroup)
                        if let answers = objects as? [SLAnswer] {
                            self.answers = answers
                        }
                    default:
                        print("error")
                        dispatch_group_leave(requestGroup)
                    }
                })
            }
            
            dispatch_group_notify(requestGroup, dispatch_get_main_queue()) {
                self.loading = false
                self.endLoading(false, error: hasError ? Constants.NetworkError : nil, completion: nil)
                if !hasError {
                    self.checkSubscriber()
                }
            }
        }
    }
    
    func checkSubscriber() {
        if let mentor = mentor {
            SLUserViewModel.sharedInstance.checkSubscriber(mentor.objectId!, success: { (status) in
                mentor.isSubscriber = status
                self.tableView.reloadData()
                }, failure: { (error) in
                    mentor.isSubscriber = false
                    self.tableView.reloadData()
                }, networkFailure: { (error) in
                    mentor.isSubscriber = false
                    self.tableView.reloadData()
            })
        }
    }
}

extension SLMentorProfileViewController {
    
    // MARK: - Actions
    
}

extension SLMentorProfileViewController {

    override func configView() {
        super.configView()
        self.tableView.registerNib(SLMentorProfileDetailTableViewCell.nib(), forCellReuseIdentifier: SLMentorProfileDetailTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLMentorProfileInfoTableViewCell.nib(), forCellReuseIdentifier: SLMentorProfileInfoTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLMentorProfileVideosTableViewCell.nib(), forCellReuseIdentifier: SLMentorProfileVideosTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLAnswerViewCell.nib(), forCellReuseIdentifier: SLAnswerViewCell.cellIdentifier())
        self.tableView.registerNib(SLMentorAnswerHeaderView.nib(), forHeaderFooterViewReuseIdentifier: SLMentorAnswerHeaderView.cellIdentifier())
        self.tableView.backgroundColor = UIColor.whiteColor()
    }
    
    func changeSubscriber(sender: LoadingButton) {
        if sender.loading {
            return
        }
        
        if let mentor = mentor {
            sender.loading = true
            SLUserViewModel.sharedInstance.changeSubscriber(mentor.objectId!, success: {
                sender.loading = false
                if let isSubscriber = mentor.isSubscriber {
                    mentor.isSubscriber = !isSubscriber
                    if mentor.isSubscriber == true {
                        mentor.subscribers? += 1
                    } else {
                        mentor.subscribers? -= 1
                    }
                }
                
                sender.setTitle((mentor.isSubscriber == true ? " Subscribed" : "  Subscribe"), forState: .Normal)
                }, failure: { (error) in
                    sender.loading = false
                    sender.setTitle((mentor.isSubscriber == true ? " Subscribed" : "  Subscribe"), forState: .Normal)
                }, networkFailure: { (error) in
                    sender.loading = false
                    sender.setTitle((mentor.isSubscriber == true ? " Subscribed" : "  Subscribe"), forState: .Normal)
            })
        }
    }
    
    func showVideoDetail(video: SLVideo) {
        let detailViewController = SLVideoDetailViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
        detailViewController.video = video
        self.presentViewController(detailViewController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? SLMentorProfileVideosTableViewCell {
            cell.updateEmptyView()
        }
    }

}

extension SLMentorProfileViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loading {
            return 0
        }
        
        if answers.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 0
        }
        
        switch section {
        case MentorProfile.Info.rawValue:
            if videos.count > 0 {
                return 3
            } else {
                return 2
            }
        case MentorProfile.Answer.rawValue:
            return answers.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case MentorProfile.Info.rawValue:
            switch indexPath.row {
            case MentorInfoSection.Detail.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(SLMentorProfileDetailTableViewCell.cellIdentifier())
                cell?.selectionStyle = .None
                
                if let mentorCell = cell as? SLMentorProfileDetailTableViewCell {
                    mentorCell.delegate = self
                    mentorCell.configCellWithData(mentor)
                    return mentorCell
                }
                
            case MentorInfoSection.Info.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(SLMentorProfileInfoTableViewCell.cellIdentifier())
                cell?.selectionStyle = .None
                
                if let infoCell = cell as? SLMentorProfileInfoTableViewCell {
                    infoCell.configCellWithData(mentor)
                    return infoCell
                }
                
            case MentorInfoSection.Video.rawValue:
                let cell = tableView.dequeueReusableCellWithIdentifier(SLMentorProfileVideosTableViewCell.cellIdentifier())
                cell?.selectionStyle = .None
                
                if let videosCell = cell as? SLMentorProfileVideosTableViewCell {
                    let videoIndexPath = NSIndexPath(forRow: TutorialType.Video.rawValue, inSection: 0)
                    videosCell.setIndexPath(videoIndexPath, sender: self)
                    videosCell.mentorDelegate = self
                    videosCell.configCellWithData(self.videos)
                    videosCell.moreButton.hidden = true
                    if self.videos.count >= Constants.LIMIT_DEFAULT_NUMBER {
                        videosCell.moreButton.hidden = false
                    }
                    return videosCell
                }
                
            default:
                return UITableViewCell()
            }
        case MentorProfile.Answer.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLAnswerViewCell.cellIdentifier())
            
            if let answerCell = cell as? SLAnswerViewCell {
                if indexPath.row < answers.count {
                    let answer = answers[indexPath.row]
                    answerCell.configCellWithData(answer)
                }
                
                if indexPath.row == 0 {
                    answerCell.topLineView.hidden = true
                } else {
                    answerCell.topLineView.hidden = false
                }
                
                if indexPath.row == answers.count - 1 {
                    answerCell.bottomLineView.hidden = true
                } else {
                    answerCell.bottomLineView.hidden = false
                }
                
                return answerCell
            }
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case MentorProfile.Info.rawValue:
            switch indexPath.row {
            case MentorInfoSection.Detail.rawValue:
                return 50
            case MentorInfoSection.Info.rawValue:
                return 50
            case MentorInfoSection.Video.rawValue:
                return 210
            default:
                return 50
            }
        case MentorProfile.Answer.rawValue:
            return 107
        default:
            return 50
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case MentorProfile.Info.rawValue:
            switch indexPath.row {
            case MentorInfoSection.Detail.rawValue:
                return UITableViewAutomaticDimension
            case MentorInfoSection.Info.rawValue:
                return UITableViewAutomaticDimension
            case MentorInfoSection.Video.rawValue:
                return 210
            default:
                return UITableViewAutomaticDimension
            }
        case MentorProfile.Answer.rawValue:
            return 107
        default:
            return UITableViewAutomaticDimension
        }
    }
}

extension SLMentorProfileViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case MentorProfile.Answer.rawValue:
            let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLMentorAnswerHeaderView.cellIdentifier())
            
            if let headerView = headerView as? SLMentorAnswerHeaderView {
                headerView.delegate = self
                headerView.moreButton.hidden = true
                if self.answers.count >= Constants.LIMIT_DEFAULT_NUMBER {
                    headerView.moreButton.hidden = false
                }
            }
            
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case MentorProfile.Answer.rawValue:
            return 33
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == MentorProfile.Answer.rawValue {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if indexPath.row < answers.count {
                let answer = answers[indexPath.row]
                if let questionId = answer.questionId {
                    let detailViewController = SLAskDetailViewController()
                    detailViewController.allowEdited = false
                    let question = SLQuestion()
                    question.objectId = questionId
                    detailViewController.question = question
                    self.navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
        }
    }
}

extension SLMentorProfileViewController {
    
    override func hasContent() -> Bool {
        return !loading
    }
    
    override func loadObject() {
        self.getMentorProfile()
    }
}

extension SLMentorProfileViewController: SLMentorAnswerHeaderViewDelegate {
    
    // MARK: - SLMentorAnswerHeaderViewDelegate
    func mentorAnswerShowMore() {
        let moreAnswers = SLMoreAnswersViewController()
        moreAnswers.navigationTitle = "Recent answers"
        if let mentorId = mentor?.objectId {
            moreAnswers.query = MentorRouter(endpoint: MentorEndpoint.GetAnswers(mentorId: mentorId))
        }
        self.navigationController?.pushViewController(moreAnswers, animated: true)
    }
}

extension SLMentorProfileViewController: MentorTutorialViewDelegate {
    
    // MARK: - MentorTutorialViewDelegate
    
    func showVideo(video: SLVideo) {
        showVideoDetail(video)
    }
    
    func showMore(indexPath: NSIndexPath?) {
        let moreVideos = SLMoreVideosViewController()
        moreVideos.navigationTitle = "Recent uploaded videos"
        moreVideos.recentUploadedVideo = true
        if let mentorId = mentor?.objectId {
            moreVideos.query = VideoRouter(endpoint: VideoEndpoint.GetVideoOfMentor(mentorId: mentorId))
        }
        self.navigationController?.pushViewController(moreVideos, animated: true)
    }
}
