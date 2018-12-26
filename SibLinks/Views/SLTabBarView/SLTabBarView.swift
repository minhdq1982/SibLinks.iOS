//
//  SLTabBarView.swift
//  SibLinks
//
//  Created by Jana on 10/7/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

enum CurrentSelected {
    case None
    case Ask
    case Video
    case Admission
    case Mentors
}

protocol SLTabBarViewDelegate {
    func selectedButtonAt(index: NSInteger)
}

class SLTabBarView: UIView {
    
    var delegate: AnyObject?
    
    @IBOutlet weak var askImageView: UIImageView!
    @IBOutlet weak var askLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var admissionImageView: UIImageView!
    @IBOutlet weak var admissionLabel: UILabel!
    @IBOutlet weak var mentorsImageView: UIImageView!
    @IBOutlet weak var mentorLabel: UILabel!
    
    var currentSelected: CurrentSelected = .Ask
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reset()
    }

    class func instanceFromNib() -> SLTabBarView {
        return UINib(nibName: "SLTabBarView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SLTabBarView
    }

}

extension SLTabBarView {
    
    // MARK: - Actions
    
    func reset() {
        let ask = UIImage(named: "Ask")!.imageWithRenderingMode(.AlwaysTemplate)
        let video = UIImage(named: "Video")!.imageWithRenderingMode(.AlwaysTemplate)
        let admission = UIImage(named: "Admission")!.imageWithRenderingMode(.AlwaysTemplate)
        let mentors = UIImage(named: "Mentors")!.imageWithRenderingMode(.AlwaysTemplate)
        
        
        self.askImageView.image = UIImage(named: "Ask")
        self.videoImageView.image = UIImage(named: "Video")
        self.admissionImageView.image = UIImage(named: "Admission")
        self.mentorsImageView.image = UIImage(named: "Mentors")
        self.askLabel.font = Constants.regularFontOfSize(12)
        self.videoLabel.font = Constants.regularFontOfSize(12)
        self.admissionLabel.font = Constants.regularFontOfSize(12)
        self.mentorLabel.font = Constants.regularFontOfSize(12)
        
        self.askImageView.tintColor = UIColor.darkGrayColor()
        self.videoImageView.tintColor = UIColor.darkGrayColor()
        self.admissionImageView.tintColor = UIColor.darkGrayColor()
        self.mentorsImageView.tintColor = UIColor.darkGrayColor()
        
        self.askLabel.textColor = UIColor.darkGrayColor()
        self.videoLabel.textColor = UIColor.darkGrayColor()
        self.admissionLabel.textColor = UIColor.darkGrayColor()
        self.mentorLabel.textColor = UIColor.darkGrayColor()
        
        switch currentSelected {
        case .Ask:
            self.askImageView.image = ask
            self.askImageView.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            self.askLabel.font = Constants.boldFontOfSize(12)
            self.askLabel.textColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            break
        case .Video:
            self.videoImageView.image = video
            self.videoImageView.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            self.videoLabel.font = Constants.boldFontOfSize(12)
            self.videoLabel.textColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            break
        case .Admission:
            self.admissionImageView.image = admission
            self.admissionImageView.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            self.admissionLabel.font = Constants.boldFontOfSize(12)
            self.admissionLabel.textColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            break
        case .Mentors:
            self.mentorsImageView.image = mentors
            self.mentorsImageView.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            self.mentorLabel.font = Constants.boldFontOfSize(12)
            self.mentorLabel.textColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            break
        default:
            return
        }
    }
    
    @IBAction func askAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLTabBarViewDelegate else {
            return
        }
        
        self.currentSelected = .Ask
        self.reset()
        delegate.selectedButtonAt(0)
    }
    
    @IBAction func videoAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLTabBarViewDelegate else {
            return
        }
        
        self.currentSelected = .Video
        self.reset()
        delegate.selectedButtonAt(1)
    }
    
    @IBAction func admissionAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLTabBarViewDelegate else {
            return
        }
        
        self.currentSelected = .Admission
        self.reset()
        delegate.selectedButtonAt(3)
    }
    
    @IBAction func mentorsAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLTabBarViewDelegate else {
            return
        }
        
        self.currentSelected = .Mentors
        self.reset()
        delegate.selectedButtonAt(4)
    }
    
}
