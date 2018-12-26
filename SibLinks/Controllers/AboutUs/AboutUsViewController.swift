//
//  AboutUsViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 11/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class AboutUsViewController: SLBaseViewController {
    
    private let aboutUsHTML = "&lt;div class=&quot;content-terms-of-use-wrapper&quot;&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;While building a tutoring website for high school students, we quickly realized that there are already plenty of great teaching resources online that, together, only attract usage from less than 10% of the high school student population. We concluded that there is a greater need for online guidance and mentoring to motivate students (apparently, a group of more than 80 colleges &mdash; including all eight in the Ivy League and many other highly selective private and public ones &mdash; recently came to the same conclusion: without mentors the set of extensive online tools that they&rsquo;ve developed are useless to those who need them the most).&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;SibLinks.com is the platform that will connect high school students to a crowd mentors from top US colleges.&amp;nbsp;Initially, our mentors are students from MIT, Harvard and Stanford universities. These students assume the roles of a sibling in college &ndash; hence our name &ndash; while advising mentees on academic as well as social topics.&amp;nbsp;&lt;strong&gt;The accessibility of these high-achieving mentors, as well as the proximity in ages, also transformed them into inspiring and attainable role models.&lt;/strong&gt;&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;To assist mentors we built the most comprehensive tutorial video collection online &ndash;encompassing all high school subjects in math and sciences, as well as the most extensive discussions of college admissions and financial aid applications &ndash; all made by successful college students in the most intuitive and creative way.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;Initially any students can come to the QA Forum and ask for any advices from our mentors. Eventually, when critical mass is reached, mentors can assist students in designing programs that effectively address their individual needs.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;The human element is a huge part of the SibLinks experience. With our flexible and low-commitment model, we are expecting a 30-fold increase in participation by mentors compared to traditional practices.&amp;nbsp;&lt;strong&gt;Our platform is built around a fundamental premise that CROWD MENTORING will bring significant improvement to our education system. We believe that hundreds of brief and simple educational interactions will engage students on a profound level.&lt;/strong&gt;&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;&lt;strong&gt;SO, ASK A QUESTION or GIVE AN ANSWER and DISCOVER the WONDERFUL SIBLINKS YOU DIDN&rsquo;T KNOW YOU HAVE!&lt;/strong&gt;&lt;/p&gt; &lt;/div&gt; &lt;/div&gt;"
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "About Us".localized
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left)])
        
        self.loading = true
        startLoading()
        aboutUsHTML.convertHTML({ (attributedString) in
            if let aboutUs = attributedString?.string {
                aboutUs.convertHTML({ (attributedString) in
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
                        
                        self.textView.attributedText = content
                    }
                    }, failure: { (error) in
                        self.endLoading()
                })
            } else {
                self.endLoading()
            }
            }, failure: { (error) in
                self.endLoading()
        })
    }
}

extension AboutUsViewController {
    override func hasContent() -> Bool {
        return !loading
    }
}
