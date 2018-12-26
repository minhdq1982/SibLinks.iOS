//
//  SLVideoDetailViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Cartography
import IBAnimatable
import AVFoundation
import PagingMenuController
import Cartography
import SDCAlertView
import Cosmos
import FBSDKShareKit
import MessageUI


enum VideoDetail: Int {
    case Content = 0
    case Info
    case Share
    case Subscriber
}

class SLVideoDetailViewController: SLBaseViewController {

    var video: SLVideo?
    var playlist: SLPlaylist?
    var admission = false
    var admissionId = 0
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerControlView: UIView!
    @IBOutlet weak var playerControlLayerView: UIView!
    let playButton = PlaybackButton(frame: CGRectMake(0, 0, 55, 55))
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var widthEqualConstraint: NSLayoutConstraint!
    @IBOutlet var heightEqualConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerLoadingView: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    let activityIndicatorView = AnimatableActivityIndicatorView(frame: CGRectMake(0, 0, 32, 32))
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var progressIndicator: UISlider!
    @IBOutlet weak var blurView: UIView!
    lazy var tapInBlur: UITapGestureRecognizer = self.createTapInView()
    private func createTapInView() -> UITapGestureRecognizer {
        let tapInBlur = UITapGestureRecognizer()
        tapInBlur.addTarget(self, action: #selector(self.tapInBlurView))
        tapInBlur.cancelsTouchesInView = false
        return tapInBlur
    }
    
    private lazy var player = Player()
    private var playerControlHidden: Bool {
        return !(self.playerControlLayerView.alpha == 1.0)
    }
    private var fullscreen = false
    private var seeking = false
    private var defaultFrame: CGRect?
    private var widthPlayerContainerConstraint: NSLayoutConstraint?
    private var heightPlayerContainerConstraint: NSLayoutConstraint?
    private var controllersTimer: NSTimer?
    private let controllersTimeoutPeriod: NSTimeInterval = 3
    private var expanded = false
    private var playlistExpanded = false
    private var savedSeparatorStyle: UITableViewCellSeparatorStyle?
    private var refreshControl = UIRefreshControl()
    private var videoPlayed = false
    private var relatedHeaderView: SLVideoDetailHeaderView?
    private var playlistHeaderView: SLVideoPlaylistHeaderView?
    private let pagingViewController = PagingMenuController(options: VideoDetailMenuOptions())
    
    var shareImageItems = ["facebook", "googole", "email"]
    var shareTitleItems = ["Facebook", "Google +", "Email"]
    var shareActionSheet: JLActionSheet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup player
        self.player.delegate = self
        self.playerView.addSubview(self.player.view)
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.playerControlView.addGestureRecognizer(tapGestureRecognizer)
        
        // Setup playback button
        self.playButton.contentEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        self.playButton.addTarget(self, action: #selector(self.didTapPlayButton(_:)), forControlEvents: .TouchUpInside)
        self.playButton.setButtonColor(UIColor.whiteColor())
        // Setup slider
        self.progressIndicator.setThumbImage(UIImage(named: "Thumb"), forState: .Normal)
        
        // Register table view
        self.tableView.registerClass(ExpandableTableViewCell.self, forCellReuseIdentifier: ExpandableTableViewCell.cellIdentifier())
        self.tableView.registerClass(SLVideoDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: SLVideoDetailHeaderView.cellIdentifier())
        self.tableView.registerNib(SLVideoPlaylistHeaderView.nib(), forHeaderFooterViewReuseIdentifier: SLVideoPlaylistHeaderView.cellIdentifier())
//        refreshControl.addTarget(self, action: #selector(SLVideoDetailViewController.refreshControlValueChanged(_:)), forControlEvents: .ValueChanged)
//        self.tableView.insertSubview(refreshControl, atIndex: 0)
        self.tableView.separatorStyle = .None
        
        loadVideo()
        
        let tapOnScreen = UITapGestureRecognizer(target: self, action: #selector(self.tapOnScreen))
        tapOnScreen.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapOnScreen)
        
        playerControlLayerView.insertSubview(playButton, belowSubview: playerLoadingView)
        activityIndicatorView.animationType = "BallClipRotate"
        activityIndicatorView.color = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        playerLoadingView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        // Set up previous, next video button
        self.previousButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.nextButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        if playlist == nil {
            self.previousButton.hidden = true
            self.nextButton.hidden = true
        } else {
            self.previousButton.hidden = false
            self.nextButton.hidden = false
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didComment), name: "did.comment", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.allowHideKeyboard), name: "comment.hide.keyboard.allow", object: nil)
        self.blurView.addGestureRecognizer(self.tapInBlur)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.stop()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if  !fullscreen {
            self.player.view.frame = self.playerView.bounds
            defaultFrame = self.playerView.bounds
        }
        
        loadingView?.frame = self.tableView.frame
        
        playButton.frame = CGRectMake((playerControlLayerView.center.x - playButton.frame.size.width/2), (playerControlLayerView.center.y - playButton.frame.size.height/2), playButton.frame.size.width, playButton.frame.size.height)
        activityIndicatorView.frame = CGRectMake((playerLoadingView.center.x - activityIndicatorView.frame.size.width/2), (playerLoadingView.center.y - activityIndicatorView.frame.size.height/2), activityIndicatorView.frame.size.width, activityIndicatorView.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapInBlurView() {
        NSNotificationCenter.defaultCenter().postNotificationName("comment.hide.keyboard", object: self.blurView)
    }
    
    func allowHideKeyboard() {
        self.blurView.hidden = true
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
        self.view.endEditing(true)
    }
    
    func didComment() {
        self.blurView.hidden = false
    }

    func loadVideo() {
        if let videoId = video?.objectId {
            loading = true
            refreshLoadingView(nil)
            if admission {
                VideoRouter(endpoint: VideoEndpoint.GetVideoAdmission(videoId: videoId)).request(completion: { (result) in
                    switch result {
                    case .Success(let objects):
                        self.loading = false
                        self.refreshLoadingView(nil)
                        self.refreshControl.endRefreshing()
                        if let videos = objects as? [SLVideo] {
                            if videos.count > 0 {
                                self.video = videos[0]
                                self.getVideoInfo()
                                self.reloadRelatedAndCommentVideo()
                                self.tableView.reloadData()
                            }
                        }
                    default:
                        self.loading = false
                        self.refreshLoadingView(Constants.RequestError)
                        self.refreshControl.endRefreshing()
                        self.dismissViewControllerAnimated(true, completion: nil)
                        Constants.showAlert("SibLinks", message: "An error occurred. Please try again later.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                    }
                })
            } else {
                VideoRouter(endpoint: VideoEndpoint.GetVideo(videoId: videoId)).request(completion: { (result) in
                    switch result {
                    case .Success(let objects):
                        self.loading = false
                        self.refreshLoadingView(nil)
                        self.refreshControl.endRefreshing()
                        if let videos = objects as? [SLVideo] {
                            if videos.count > 0 {
                                self.video = videos[0]
                                self.getVideoInfo()
                                self.reloadRelatedAndCommentVideo()
                                self.tableView.reloadData()
                            }
                        }
                    default:
                        self.loading = false
                        self.refreshLoadingView(Constants.RequestError)
                        self.refreshControl.endRefreshing()
                        self.dismissViewControllerAnimated(true, completion: nil)
                        Constants.showAlert("SibLinks", message: "An error occurred. Please try again later.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                    }
                })
            }
        }
    }
    
    func getVideoInfo() {
        if let videoLink = self.video?.videoLink {
            // Pause player
            player.pause()
            // Animating activity indicator
            playerLoadingView.hidden = false
            activityIndicatorView.startAnimating()
            self.playVideoWithYoutubeURL(NSURL(string: videoLink)!)
        }
        
        if !admission {
            checkSubscriber()
            checkFavourite()
            checkRating()
        }
    }
    
    func playVideoWithYoutubeURL(url: NSURL) {
        Youtube.h264videosWithYoutubeURL(url) { (videoDictionary) in
            let videoMediumURL = videoDictionary["medium"]
            if let urlStr = videoMediumURL {
                self.player.setUrl(NSURL(string: urlStr)!)
            } else {
                self.playButton.setButtonState(PlaybackButtonState.Pending, animated: true)
            }
        }
    }
    
    // MARK: - Action
    @objc private func refreshControlValueChanged(refreshControl: UIRefreshControl) {
        if !loading {
            loadVideo()
        }
    }
    
    @IBAction func dismissPlayer(sender: AnyObject) {
        if playerControlHidden {
            handleTapGestureRecognizer(nil)
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapPlayButton(sender: AnyObject) {
        if playerControlHidden {
            handleTapGestureRecognizer(nil)
            return
        }
        
        if !videoPlayed {
            if let video = video {
                if let videoId = video.objectId {
                    if admission {
                        // View video
                        VideoRouter(endpoint: VideoEndpoint.UpdateVideoViewAdmission(videoId: videoId)).request(completion: { (result) in
                            switch result {
                            case .Ok:
                                print("Update video view successful")
                            default:
                                print("Error")
                            }
                        })
                    }else {
                        // History video
                        VideoRouter(endpoint: VideoEndpoint.HistoryAdded(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId)).request(completion: { (result) in
                            switch result {
                            case .Ok:
                                print("History added successful")
                            default:
                                print("Error")
                            }
                        })
                        
                        // View video
                        VideoRouter(endpoint: VideoEndpoint.UpdateVideoView(videoId: videoId)).request(completion: { (result) in
                            switch result {
                            case .Ok:
                                print("Update video view successful")
                            default:
                                print("Error")
                            }
                        })
                    }
                }
            }
            
        }
        
        videoPlayed = true
        if self.playButton.buttonState == .Playing {
            self.playButton.setButtonState(.Pausing, animated: true)
            self.player.pause()
        } else if self.playButton.buttonState == .Pausing {
            self.playButton.setButtonState(.Playing, animated: true)
            switch (self.player.playbackState.rawValue) {
            case PlaybackState.Stopped.rawValue:
                self.player.playFromBeginning()
                break
            case PlaybackState.Paused.rawValue:
                self.player.playFromCurrentTime()
                break
            default:
                self.player.pause()
                break
            }
        }
        
        showControlPlayerView()
    }
    
    @IBAction func changePlayerState(sender: UIButton) {
        if fullscreen {
            sender.setImage(UIImage(named: "Fullscreen"), forState: .Normal)
            var constraints = [NSLayoutConstraint]()
            if let widthConstraint = widthPlayerContainerConstraint {
                constraints.append(widthConstraint)
            }
            if let heightConstraint = heightPlayerContainerConstraint {
                constraints.append(heightConstraint)
            }
            self.playerContainerView.removeConstraints(constraints)
            widthPlayerContainerConstraint = nil
            heightPlayerContainerConstraint = nil
            self.view.addConstraints([self.widthEqualConstraint, self.heightEqualConstraint])
            self.topConstraint.constant = 0
            UIView.animateWithDuration(0.3, animations: {
                self.tableView.alpha = 1
                self.playerContainerView.transform = CGAffineTransformIdentity
                if let defaultFrame = self.defaultFrame {
                    self.player.view.frame = defaultFrame
                }
            })
        } else {
            sender.setImage(UIImage(named: "Minimize"), forState: .Normal)
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            var width = UIScreen.mainScreen().bounds.size.width
            var height = UIScreen.mainScreen().bounds.size.height
            if UIInterfaceOrientationIsPortrait(orientation) {
                let aux = width
                width = height
                height = aux
            }
            
            self.view.removeConstraints([self.widthEqualConstraint, heightEqualConstraint])
            constrain(self.playerContainerView) { view in
                self.widthPlayerContainerConstraint = (view.width == width)
                self.heightPlayerContainerConstraint = (view.height == height)
            }
            self.topConstraint.constant = (width-height)/2
            UIView.animateWithDuration(0.3, animations: {
                self.tableView.alpha = 0
                self.playerContainerView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
                self.player.view.frame = CGRectMake(0, 0, width, height)
            })
        }
        
        fullscreen = !fullscreen
        showControlPlayerView()
    }
    
    @IBAction func seek(sender: AnyObject) {
        self.player.seekToTime(CMTimeMake(Int64(progressIndicator.value*100), 100))
        showControlPlayerView()
    }
    
    @IBAction func pauseRefreshing(sender: AnyObject) {
        seeking = true
    }
    
    @IBAction func resumeInRefreshing(sender: AnyObject) {
        seeking = false
    }
    
    @IBAction func resumeOutRefreshing(sender: AnyObject) {
        seeking = false
    }
    
    func openPlaylistHeader() {
        playlistExpanded = !playlistExpanded
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .None, animated: false)
        tableView.reloadData()
        tableView.scrollEnabled = !playlistExpanded
    }
    
    func openRelatedAndCommentOfVideoHeader() {
        if self.tableView.indexPathsForVisibleRows?.count != 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: NSNotFound, inSection: 1), atScrollPosition: .Top, animated: true)
        }
    }
    
    func changeSubscriber(sender: LoadingButton) {
        if sender.loading {
            return
        }
        
        if let mentor = video?.mentor {
            if let mentorId = mentor.objectId {
                sender.loading = true
                sender.setActivityIndicatorStyle(.Gray, state: .Normal)
                
                SLUserViewModel.sharedInstance.changeSubscriber(mentorId, success: {
                    sender.loading = false
                    if let isSubscriber = mentor.isSubscriber {
                        mentor.isSubscriber = !isSubscriber
                    }
                    
                    if mentor.isSubscriber == true {
                        sender.tintColor = colorFromHex(Constants.SIBLINKS_UNSUBSCRIBER_COLOR)
                        sender.setImage(UIImage(named: "status-subscribe")!, state: .Normal)
                    } else {
                        sender.tintColor = colorFromHex(Constants.SIBLINKS_SUBSCRIBER_COLOR)
                        sender.setImage(UIImage(named: "status-unsubscribe")!, state: .Normal)
                    }
                    
                    }, failure: { (error) in
                        sender.loading = false
                        sender.setTitle((mentor.isSubscriber == true ? " Subscribed".localized : " Subscribe").localized, forState: .Normal)
                        sender.setImage((mentor.isSubscriber == true ? UIImage(named: "status-unsubscribe")! : UIImage(named: "status-subscribe")!), state: .Normal)
                        sender.fillColor = (mentor.isSubscriber == true) ? UIColor(hexString: Constants.SIBLINKS_UNSUBSCRIBER_COLOR) : UIColor(hexString: Constants.SIBLINKS_SUBSCRIBER_COLOR)
                    }, networkFailure: { (error) in
                        sender.loading = false
                        sender.setTitle((mentor.isSubscriber == true ? " Subscribed".localized : " Subscribe").localized, forState: .Normal)
                        sender.setImage((mentor.isSubscriber == true ? UIImage(named: "status-unsubscribe")! : UIImage(named: "status-subscribe")!), state: .Normal)
                        sender.fillColor = (mentor.isSubscriber == true) ? UIColor(hexString: Constants.SIBLINKS_UNSUBSCRIBER_COLOR) : UIColor(hexString: Constants.SIBLINKS_SUBSCRIBER_COLOR)
                })
            }
        }
    }
    
    func checkSubscriber() {
        if let mentor = video?.mentor {
            if let mentorId = mentor.objectId {
                SLUserViewModel.sharedInstance.checkSubscriber(mentorId, success: { (status) in
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
    
    func checkFavourite() {
        if let videoId = video?.objectId {
            VideoRouter(endpoint: VideoEndpoint.CheckFavourite(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId)).request(completion: { (result) in
                switch result {
                case .Success(let status):
                    if let status = status as? Bool {
                        self.video?.isFavourited = status
                        self.tableView.reloadData()
                    }
                default:
                    self.video?.isFavourited = false
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func checkRating() {
        if let videoId = video?.objectId {
            VideoRouter(endpoint: VideoEndpoint.CheckRating(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId)).request(completion: { (result) in
                switch result {
                case .Success(let status):
                    if let status = status as? Bool {
                        self.video?.isRated = status
                        self.tableView.reloadData()
                    }
                default:
                    self.video?.isRated = false
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func changeVideo(video: SLVideo, addedPlaylist: Bool) {
        if !addedPlaylist {
            playlist = nil
        }
        
        self.video = video
        let index = getIndexVideoInPlaylist()
        if let videos = playlist?.videos {
            if let headerView = tableView.headerViewForSection(0) as? SLVideoPlaylistHeaderView {
                headerView.totalVideoLabel.text = "\(index+1)/\(videos.count)"
            }
        }
        loadVideo()
    }
    
    @IBAction func previousVideo(sender: AnyObject) {
        playVideoInPlaylist(false)
    }
    
    @IBAction func nextVideo(sender: AnyObject) {
        playVideoInPlaylist(true)
    }
    
    func updateVideoPlaylist(videos: [SLVideo]) {
        self.playlist?.videos = videos
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(CDouble(0.5) * CDouble(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            let index = self.getIndexVideoInPlaylist()
            if index >= 0 {
                for viewController in self.childViewControllers {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    if let videoViewController = viewController as? SLVideoOfPlaylistViewController {
                        videoViewController.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                        break
                    }
                }
            }
            
            if let headerView = self.tableView.headerViewForSection(0) as? SLVideoPlaylistHeaderView {
                headerView.configCellWithData(self.playlist)
                headerView.totalVideoLabel.text = "\(index+1)/\(videos.count)"
            }
        }
    }
    
    private func playVideoInPlaylist(next: Bool) {
        var index = getIndexVideoInPlaylist()
        if next {
            index += 1
        } else {
            index -= 1
        }
        
        if let videos = playlist?.videos {
            if index >= 0 && index < videos.count {
                video = videos[index]
                loadVideo()
                getIndexVideoInPlaylist()
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                for viewController in childViewControllers {
                    if let videoViewController = viewController as? SLVideoOfPlaylistViewController {
                        videoViewController.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                        break
                    }
                }
                // Change index/total video playlist
                if let headerView = tableView.headerViewForSection(0) as? SLVideoPlaylistHeaderView {
                    headerView.totalVideoLabel.text = "\(index + 1)/\(videos.count)"
                }
            }else {
                print("End next, previous playlist")
            }
        }
    }
    
    private func getIndexVideoInPlaylist() -> Int {
        var index = -1
        if let videoId = video?.objectId, let videos = playlist?.videos {
            for video in videos {
                if let objectId = video.objectId {
                    if objectId == videoId {
                        if let row = videos.indexOf(video) {
                            index = row
                            break
                        }
                    }
                }
            }
            
            if index == 0 {
                previousButton.hidden = true
                nextButton.hidden = false
            } else if index == (videos.count - 1) {
                previousButton.hidden = false
                nextButton.hidden = true
            } else {
                previousButton.hidden = false
                nextButton.hidden = false
            }
        } else {
            previousButton.hidden = true
            nextButton.hidden = true
        }
        
        return index
    }
    
    func showMentorProfile() {
        if let mentor = video?.mentor {
            let mentorDetailController = SLMentorProfileViewController.controller
            mentorDetailController.mentor = mentor
            let navigationController = UINavigationController(rootViewController: mentorDetailController)
            presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: UIGestureRecognizer
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer?) {
        if !playerLoadingView.hidden {
            return
        }
        
        if playerControlLayerView.alpha == 1.0 {
            hideControlPlayerView()
        } else {
            showControlPlayerView()
        }
        
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
        self.view.endEditing(true)
    }
    
    func showControlPlayerView() {
        UIView.animateWithDuration(0.3, animations: { 
            self.playerControlLayerView.alpha = 1.0
            }) { (finished) in
                self.controllersTimer?.invalidate()
                self.controllersTimer = NSTimer.scheduledTimerWithTimeInterval(self.controllersTimeoutPeriod, target: self, selector: #selector(self.hideControlPlayerView), userInfo: nil, repeats: false)
        }
    }
    
    func hideControlPlayerView() {
        UIView.animateWithDuration(0.3, animations: {
            self.playerControlLayerView.alpha = 0
        })
    }
}

extension SLVideoDetailViewController: SLVideoDetailShareViewCellDelegate {
    
    // MARK: - SLVideoDetailShareViewCellDelegate
    func favouriteVideo(sender: LoadingButton, cell: UITableViewCell) {
        if sender.loading == true {
            return
        }
        
        if let video = video {
            if let favourite = video.isFavourited {
                sender.loading = true
                
                if favourite {
                    SLVideoViewModel.sharedInstance.removeVideoFavourite(video.objectId!, success: {
                        self.video?.isFavourited = false
                        sender.loading = false
                        sender.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
                        if let shareCell = cell as? SLVideoDetailShareViewCell {
                            if let value = shareCell.favouriteLabel.text?.toInt() {
                                let currentValue = value - 1
                                shareCell.favouriteLabel.text = "\(currentValue)"
                            }
                        }
                        }, failure: { (error) in
                            sender.loading = false
                            sender.tintColor = (self.video?.isFavourited == true) ?  UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR) : UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
                        }, networkFailure: nil)
                } else {
                    SLVideoViewModel.sharedInstance.addVideoToFavourite(video.objectId!, success: {
                        self.video?.isFavourited = true
                        sender.loading = false
                        sender.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
                        if let shareCell = cell as? SLVideoDetailShareViewCell {
                            if let value = shareCell.favouriteLabel.text?.toInt() {
                                let currentValue = value + 1
                                shareCell.favouriteLabel.text = "\(currentValue)"
                            }
                        }
                        }, failure: { (error) in
                            sender.loading = false
                            sender.tintColor = (self.video?.isFavourited == true) ?  UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR) : UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
                        }, networkFailure: nil)
                }
            }
            
        }
    }
    
    func rateVideo(sender: LoadingButton, cell: UITableViewCell) {
        let ratingView = CosmosView()
        ratingView.rating = 0
        ratingView.settings.filledColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        ratingView.settings.filledBorderColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        ratingView.settings.emptyBorderColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        
        let rateAlert = AlertController(title: "Rate Video!", message: "How much do you like this video?")
        let notNowAction = AlertAction(title: "Not Now", style: .Default, handler: nil)
        rateAlert.addAction(notNowAction)
        let noThanksAction = AlertAction(title: "Send", style: .Preferred) { (action) in
            if ratingView.rating > 0 {
                if let videoId = self.video?.objectId {
                    SLVideoViewModel.sharedInstance.ratingVideo((SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId, rating: Int(ratingView.rating), success: {
                        sender.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
                        if let shareCell = cell as? SLVideoDetailShareViewCell {
                            if let value = shareCell.ratingLabel.text?.toInt() {
                                let currentValue = value + 1
                                shareCell.ratingLabel.text = "\(currentValue)"
                                
                                if self.video?.isRated == false {
                                    self.video?.isRated = true
                                    self.video?.numberOfRatings = currentValue
                                }
                            }
                        }
                        }, failure: { (error) in
                            print("Rating error: \(error)")
                        }, networkFailure: nil)
                }
            } else {
                print("Rating error: star equal zero)")
            }
        }
        
        rateAlert.addAction(noThanksAction)
        
        let contentView = rateAlert.contentView
        contentView.addSubview(ratingView)
        constrain(ratingView) { view in
            view.centerX == view.superview!.centerX
            view.top == view.superview!.top
            view.bottom == view.superview!.bottom
        }
        
        rateAlert.present()
    }
    
    func shareVideo(sender: AnyObject, cell: UITableViewCell) {
        self.shareActionSheet = nil
        self.shareActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.shareActionSheet?.tableView.registerNib(SLShareVideoTableViewCell.nib(), forCellReuseIdentifier: SLShareVideoTableViewCell.cellIdentifier())
        self.shareActionSheet?.show()
    }
}

extension SLVideoDetailViewController: PlayerDelegate {
    // MARK: PlayerDelegate
    func playerReady(player: Player) {
        if !isnan(player.currentTime) {
            playerLoadingView.hidden = true
            self.currentTimeLabel.text = Constants.secondsToHoursMinutesSeconds(Int(player.currentTime))
            self.totalTimeLabel.text = Constants.secondsToHoursMinutesSeconds(Int(player.maximumDuration))
            self.progressIndicator.maximumValue = Float(player.maximumDuration)
            self.progressIndicator.minimumValue = 0
            self.progressIndicator.value = Float(player.currentTime)
            self.playerControlLayerView.alpha = 1.0
            self.playButton.setButtonState(.Pausing, animated: true)
            self.player.pause()
            self.didTapPlayButton(self.playButton)
        }
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        
    }
    
    func playerBufferingStateDidChange(player: Player) {
        
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
        
    }
    
    func playerPlaybackDidEnd(player: Player) {
        if playlist?.videos?.count > 0 {
            playVideoInPlaylist(true)
        }
    }
    
    func playerCurrentTimeDidChange(player: Player) {
        if !isnan(player.currentTime) {
            self.currentTimeLabel.text = Constants.secondsToHoursMinutesSeconds(Int(player.currentTime))
            self.progressIndicator.value = Float(player.currentTime)
        }
    }
}

extension SLVideoDetailViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.row {
        case VideoDetail.Content.rawValue:
            if let contentCell = tableView.dequeueReusableCellWithIdentifier(ExpandableTableViewCell.cellIdentifier()) as? ExpandableTableViewCell {
                contentCell.setCellContent(self.video, isExpanded: expanded)
                contentCell.selectionStyle = .None
                
                return contentCell
            }
        case VideoDetail.Subscriber.rawValue:
            if let subscriberCell = tableView.dequeueReusableCellWithIdentifier(SLVideoDetailSubscribeViewCell.cellIdentifier()) as? SLVideoDetailSubscribeViewCell {
                subscriberCell.delegate = self
                subscriberCell.configCellWithData(self.video?.mentor)
                return subscriberCell
            }
        case VideoDetail.Info.rawValue:
            if let infoCell = tableView.dequeueReusableCellWithIdentifier(SLVideoInfoViewCell.cellIdentifier()) as? SLVideoInfoViewCell {
                infoCell.configCellWithData(self.video)
                
                return infoCell
            }
        case VideoDetail.Share.rawValue:
            if let shareCell = tableView.dequeueReusableCellWithIdentifier(SLVideoDetailShareViewCell.cellIdentifier()) as? SLVideoDetailShareViewCell {
                shareCell.setIndexPath(indexPath, sender: self)
                shareCell.configCellWithData(self.video)
                
                return shareCell
            }
        default:
            return cell
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loading {
            return 0
        }
        
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 0
        }
        
        switch section {
        case 0:
            return 4
        default:
            return 0
        }
    }
}

extension SLVideoDetailViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case VideoDetail.Content.rawValue:
            return UITableViewAutomaticDimension
        case VideoDetail.Subscriber.rawValue:
            return 66
        case VideoDetail.Info.rawValue:
            return 26
        case VideoDetail.Share.rawValue:
            return 26
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case VideoDetail.Content.rawValue:
            return self.dynamicCellHeight(indexPath)
        case VideoDetail.Subscriber.rawValue:
            return 66
        case VideoDetail.Info.rawValue:
            return 26
        case VideoDetail.Share.rawValue:
            return 26
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0, let headerView = playlistHeaderView {
            if self.playlist != nil {
                return headerView
            } else {
                return nil
            }
        } else if section == 1, let headerView = relatedHeaderView {
            return headerView
        }
        
        if section == 0 {
            if let playlist = playlist {
                let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLVideoPlaylistHeaderView.cellIdentifier())
                if let playlistHeader = headerView as? SLVideoPlaylistHeaderView {
                    self.playlistHeaderView = playlistHeader
                    playlistHeader.delegate = self
                    playlistHeader.configCellWithData(playlist)
                    
                    let videoViewController = SLVideoOfPlaylistViewController(style: .Plain)
                    videoViewController.paginationEnabled = !admission
                    videoViewController.delegate = self
                    videoViewController.playlist = playlist
                    addChildViewController(videoViewController)
                    playlistHeader.containerView.addSubview(videoViewController.view)
                    videoViewController.didMoveToParentViewController(self)
                    let index = getIndexVideoInPlaylist()
                    if index >= 0 {
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                        videoViewController.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                    }
                    
                    constrain(videoViewController.view) { view in
                        view.size   == view.superview!.size
                        view.center == view.superview!.center
                    }
                }
                
                return headerView
            } else {
                return nil
            }
        } else if section == 1 {
            let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLVideoDetailHeaderView.cellIdentifier())
            if let detailHeader = headerView as? SLVideoDetailHeaderView {
                self.relatedHeaderView = detailHeader
                
                reloadRelatedAndCommentVideo()
                
                pagingViewController.delegate = self
                addChildViewController(pagingViewController)
                headerView?.contentView.addSubview(pagingViewController.view)
                pagingViewController.didMoveToParentViewController(self)
                constrain(pagingViewController.view) { view in
                    view.size   == view.superview!.size
                    view.center == view.superview!.center
                }
            }
            
            return headerView
        }
        
        return nil
    }
    
    func reloadRelatedAndCommentVideo() {
        if let controller = pagingViewController.pagingViewController?.controllers[0] as? SLVideoRelatedViewController {
            controller.delegate = self
            controller.video = self.video
            controller.admission = self.admission
            controller.admissionId = self.admissionId
            controller.paginationEnabled = !self.admission
            controller.loadObjects()
        }
        
        if let controller = pagingViewController.pagingViewController?.controllers[1] as? SLVideoCommentViewController {
            for menuItemView in (pagingViewController.menuView?.subviews[0].subviews)! {
                if menuItemView is MenuItemView {
                    controller.menuItemView = menuItemView as? MenuItemView
                }
            }
            controller.delegate = self
            controller.video = self.video
            controller.admission = self.admission
            controller.loadObjects()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return self.playlist != nil ? (playlistExpanded ? UIScreen.mainScreen().bounds.size.height - (UIScreen.mainScreen().bounds.size.height*0.315) : 44) : 0
        } else if section == 1 {
            return UIScreen.mainScreen().bounds.size.height - (UIScreen.mainScreen().bounds.size.height*0.315)
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case VideoDetail.Content.rawValue:
            expanded = !expanded
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            return
        }
        
    }
    
    // MARK: - Compute cell height
    private func dynamicCellHeight(indexPath:NSIndexPath)->CGFloat {
        struct StaticStruct {
            static var sizingCell : ExpandableTableViewCell?
            static var onceToken : dispatch_once_t = 0
        } // workaround to add static variables inside function in swift
        
        dispatch_once(&StaticStruct.onceToken) { () -> Void in
            StaticStruct.sizingCell = self.tableView.dequeueReusableCellWithIdentifier(ExpandableTableViewCell.cellIdentifier()) as? ExpandableTableViewCell
        }
        
        StaticStruct.sizingCell?.setCellContent(nil, isExpanded: expanded)
        StaticStruct.sizingCell?.setNeedsUpdateConstraints()
        StaticStruct.sizingCell?.updateConstraintsIfNeeded()
        StaticStruct.sizingCell?.setNeedsLayout()
        StaticStruct.sizingCell?.layoutIfNeeded()
        guard let height = StaticStruct.sizingCell?.cellContentHeight() else {
            return 0
        }
        return height
    }
}

extension SLVideoDetailViewController {
    
    // MARK: - Loading View
    
    private func refreshLoadingView(error: NSError?) {
        if let loadingView = loadingView as? SLLoadingView {
            if loading {
                startLoading(false, completion: nil)
                loadingView.activityIndicator.startAnimating()
                playerLoadingView.hidden = false
                activityIndicatorView.startAnimating()
            } else {
                loadingView.activityIndicator.stopAnimating()
                endLoading(false, error: error, completion: nil)
            }
        }
    }
}

extension SLVideoDetailViewController {
    
    // MARK: - Tap on screen
    
    func tapOnScreen() {
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
        self.view.endEditing(true)
    }
}

extension SLVideoDetailViewController: JLActionSheetDataSource {
    
    // MARK: - JLActionSheetDataSource
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shareTitleItems.count
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLShareVideoTableViewCell.cellIdentifier())
        
        if let shareCell = cell as? SLShareVideoTableViewCell {
            shareCell.shareTitleLabel.text = self.shareTitleItems[indexPath.row]
            return shareCell
        }
        
        return UITableViewCell()
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func JLActionSheetDataSourceHeightOfContentView() -> CGFloat {
        if self.shareTitleItems.count >= 3 {
            return 132
        }
        return CGFloat(self.shareTitleItems.count) * 44
    }
}

extension SLVideoDetailViewController: JLActionSheetDelegate {
    
    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.shareActionSheet?.dismiss()
        switch indexPath.row {
        case 0:
            // Facebook
            if let url = self.video?.videoLink {
                let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
                print("Link: \(self.video?.videoLink)")
                content.contentURL = NSURL(string: "\(url)")
                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
            }
            
        case 1:
            // Google plus
            if let url = self.video?.videoLink {
                print(url)
            }
            
        case 2:
            // Email
            if let url = self.video?.videoLink {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([""])
                    mail.setMessageBody("<b>\(url)</b>", isHTML: true)
                    presentViewController(mail, animated: true, completion: nil)
                } else {
                    print("Cannot send mail")
                }
            }
            
        default:
            return
        }
    }
    
}

extension SLVideoDetailViewController: MFMailComposeViewControllerDelegate {
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            print("Cancelled")
        case MFMailComposeResultSaved:
            print("Saved")
        case MFMailComposeResultSent:
            print("Sent")
        case MFMailComposeResultFailed:
            print("Failed")
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SLVideoDetailViewController: PagingMenuControllerDelegate {
    
    // MARK: - PagingMenuControllerDelegate
    
    func willMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        
    }
    
    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        
    }
    
    func willMoveToMenuItemView(menuItemView: MenuItemView, previousMenuItemView: MenuItemView) {
        
    }
    
    func didMoveToMenuItemView(menuItemView: MenuItemView, previousMenuItemView: MenuItemView) {
        
    }
}

extension SLVideoDetailViewController {
    override func hasContent() -> Bool {
        return !loading
    }
}
