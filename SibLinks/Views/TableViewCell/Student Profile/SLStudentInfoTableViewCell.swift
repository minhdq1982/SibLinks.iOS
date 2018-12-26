//
//  SLStudentInfoTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Kingfisher
import IBAnimatable

protocol SLStudentInfoTableViewCellDelegate {
    func editProfileAction()
}

class SLStudentInfoTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var avatarButton: AnimatableButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var birthdayAndGenderLabel: UILabel!
    @IBOutlet weak var favoriteSubjectsLabel: UILabel!
    @IBOutlet weak var editProfileButton: AnimatableButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

extension SLStudentInfoTableViewCell {
    
    // MARK: - Configure
    
    override static func cellIdentifier() -> String {
        return "SLStudentInfoTableViewCell"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let user = data as? SLUser {
            self.avatarButton.kf_setBackgroundImageWithURL(NSURL(string: user.imageUrl ?? ""), forState: .Normal, placeholderImage: Constants.noAvatarImage, optionsInfo: nil, progressBlock: nil, completionHandler: nil)
            
            var username = user.name()
            if username.characters.count > 0 {
                if let email = user.email {
                    let emails = email.componentsSeparatedByString("@")
                    if emails.count > 0 {
                        username = emails[0]
                    } else {
                        username = email
                    }
                }
            }
            
            self.usernameLabel.text = username
            
            var schoolString = ""
            let schoolId = "\(user.school ?? "")".toInt()
            for school in Constants.appDelegate().university {
                if school.objectId == schoolId {
                    if let schoolName = school.name {
                        schoolString = schoolName
                    } else {
                        schoolString = "N/A"
                    }
                }
            }
            self.educationLabel.text = schoolString
            
            self.birthdayAndGenderLabel.text = user.birthdayAndGender()
            
            var subjectString = ""
            let subjectIdArray = user.defaultSubjectId?.componentsSeparatedByString(",")
            if let subjectIdArray = subjectIdArray {
                for index in 0 ..< subjectIdArray.count {
                    for category in Constants.appDelegate().categories {
                        if category.objectId == "\(subjectIdArray[index])".toInt() {
                            if subjectString == "" {
                                subjectString += "\(category.subject ?? "")"
                            } else {
                                subjectString += ", \(category.subject ?? "")"
                            }
                        }
                    }
                }
            }
            self.favoriteSubjectsLabel.text = "Favorite Subjects: \(subjectString)"
        }
    }
}

extension SLStudentInfoTableViewCell {
    
    // MARK: - Actions
    
    @IBAction func editProfileAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLStudentInfoTableViewCellDelegate else {
            return
        }
        
        delegate.editProfileAction()
    }
    
}
