//
//  SLStudentProfileViewController.swift
//  SibLinks
//
//  Created by Jana on 9/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
enum StudentProfileType: Int {
    case Information = 0
    case Number = 1
    case Subscriptions = 2
}

class SLStudentProfileViewController: SLBaseViewController {

    static let studentProfileViewControllerID = "SLStudentProfileViewControllerID"
    
    static var controller: SLStudentProfileViewController! {
        let controller = UIStoryboard(name: Constants.STUDENT_PROFILE_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SLStudentProfileViewController.studentProfileViewControllerID) as! SLStudentProfileViewController
        return controller
    }
    
    var userViewModel = SLUserViewModel.sharedInstance
    
    @IBOutlet weak var tableView: UITableView!
    private var mentors = [SLMentor]()
    private var user: SLUser?
    private lazy var categories: [SLCategory] = self.createCategories()
    private func createCategories() -> [SLCategory] {
        var categories = [SLCategory]()
        categories = Constants.appDelegate().categories
        
        let all = SLCategory()
        all.objectId = -1
        all.subject = "All"
        categories.insert(all, atIndex: 0)
        
        return categories
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserProfile()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getMentorList), name: Constants.SUBSCRIBER_CHANGE, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "My Profile".localized
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? SLStudentSubscribedMentorsTableViewCell {
            cell.updateEmptyView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserProfile() {
        self.tableView.reloadData()
        getUserProfile()
    }
    
    func getUserProfile() {
        startLoading(false, completion: nil)
        let requestGroup = dispatch_group_create()
        var hasError = false
        // Get user profile
        dispatch_group_enter(requestGroup)
        self.userViewModel.getProfileWithUserId((SLUserViewModel.sharedInstance.currentUser?.userId)!, success: { (user) in
            dispatch_group_leave(requestGroup)
            self.user = user
            }, failure: { (error) in
                // Error
                dispatch_group_leave(requestGroup)
                hasError = true
            }, networkFailure: { (error) in
                // Error
                dispatch_group_leave(requestGroup)
                hasError = true
        })
        
        // Get mentors of user
        dispatch_group_enter(requestGroup)
        UserRouter(endpoint: UserEndpoint.GetSubscribers(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!)).request { (result) in
            switch result {
            case .Success(let objects):
                dispatch_group_leave(requestGroup)
                if let mentors = objects as? [SLMentor] {
                    self.mentors = mentors
                    self.tableView.reloadData()
                }
            default:
                dispatch_group_leave(requestGroup)
                print("error")
            }
        }
        
        dispatch_group_notify(requestGroup, dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.endLoading(false, error: hasError ? Constants.NetworkError : nil, completion: nil)
        }
    }
    
    func getMentorList() {
        UserRouter(endpoint: UserEndpoint.GetSubscribers(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!)).request { (result) in
            switch result {
            case .Success(let objects):
                if let mentors = objects as? [SLMentor] {
                    self.mentors = mentors
                } else {
                    self.mentors.removeAll()
                }
                self.tableView.reloadData()
            default:
                print("error")
            }
        }
    }
}

extension SLStudentProfileViewController {
    
    // MARK: - Configure
    
    override func configView() {
        super.configView()
        
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left)])
        
        // Register
        self.tableView.registerNib(SLStudentInfoTableViewCell.nib(), forCellReuseIdentifier: SLStudentInfoTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLStudentAccountInfoTableViewCell.nib(), forCellReuseIdentifier: SLStudentAccountInfoTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLStudentSubscribedMentorsTableViewCell.nib(), forCellReuseIdentifier: SLStudentSubscribedMentorsTableViewCell.cellIdentifier())
        
        self.tableView.allowsSelection = false
    }
}

extension SLStudentProfileViewController {
    
    // MARK: - Actions
    func showMentorProfile(mentor: SLMentor) {
        let mentorDetailController = SLMentorProfileViewController.controller
        mentorDetailController.mentor = mentor
        self.navigationController?.pushViewController(mentorDetailController, animated: true)
    }
    
    func openTopMentor() {
        if let sideMenuViewController = self.sideMenuViewController {
            if let tabBarController = sideMenuViewController.contentViewController as? SLTabBarViewController {
                tabBarController.selectedButtonAt(Constants.TAB_BAR_MENTOR_NUMBER)
            }
        }
    }
}

extension SLStudentProfileViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user == nil {
            return 0
        }
        
        return 3
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case StudentProfileType.Subscriptions.rawValue:
            return 170
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case StudentProfileType.Information.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLStudentInfoTableViewCell.cellIdentifier())
            if let infoCell = cell as? SLStudentInfoTableViewCell {
                infoCell.setIndexPath(indexPath, sender: self)
                infoCell.configCellWithData(user)
                return infoCell
            }
            
        case StudentProfileType.Number.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLStudentAccountInfoTableViewCell.cellIdentifier())
            if let accountInfoCell = cell as? SLStudentAccountInfoTableViewCell {
                accountInfoCell.setIndexPath(indexPath, sender: self)
                accountInfoCell.configCellWithData(user)
                return accountInfoCell
            }
            
        case StudentProfileType.Subscriptions.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLStudentSubscribedMentorsTableViewCell.cellIdentifier())
            
            if let mentorCell = cell as? SLStudentSubscribedMentorsTableViewCell {
                mentorCell.setIndexPath(indexPath, sender: self)
                mentorCell.moreButton.hidden = true
                if mentors.count >= Constants.LIMIT_DEFAULT_NUMBER {
                    mentorCell.moreButton.hidden = false
                }
                mentorCell.mentors = mentors
                mentorCell.addEmptyView()
                mentorCell.collectionView.reloadData()
                return mentorCell
            }
        
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
}

extension SLStudentProfileViewController: SLStudentInfoTableViewCellDelegate {
    
    // MARK: - SLStudentInfoTableViewCellDelegate
    
    func editProfileAction() {
        self.performSegueWithIdentifier(Constants.EDIT_STUDENT_PROFILE, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.EDIT_STUDENT_PROFILE {
            if let viewController = segue.destinationViewController as? SLEditStudentProfileViewController {
                viewController.user = user
                viewController.delegate = self
            }
        }
    }
}

extension SLStudentProfileViewController: SLStudentSubscribedMentorsTableViewCellDelegate {
    
    // MARK: - SLStudentSubscribedMentorsTableViewCellDelegate
    func studentSubscribedMentorsShowMore() {
        let moreMentors = SLMoreMentorsViewController()
        moreMentors.navigationTitle = "Subscriptions".localized
        moreMentors.query = UserRouter(endpoint: UserEndpoint.GetSubscribers(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!))
        self.navigationController?.pushViewController(moreMentors, animated: true)
    }
}

extension SLStudentProfileViewController {
    override func hasContent() -> Bool {
        return user != nil
    }
    
    override func loadObject() {
        self.getUserProfile()
    }
}
