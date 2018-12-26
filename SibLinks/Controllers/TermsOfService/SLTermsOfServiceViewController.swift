//
//  SLTermsOfServiceViewController.swift
//  SibLinks
//
//  Created by Jana on 11/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLTermsOfServiceViewController: SLBaseViewController {

    static let nibName = "SLTermsOfServiceViewController"
    static var controller: SLTermsOfServiceViewController! {
        let controller = SLTermsOfServiceViewController(nibName: SLTermsOfServiceViewController.nibName, bundle: nil)
        return controller
    }
    
    private let termsOfServiceHTML = "&lt;div class=&quot;content-terms-of-use&quot;&gt; &lt;div class=&quot;content-terms-of-use-wrapper&quot;&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;By accessing this web site, you are agreeing to be bound by these web site Terms and Conditions of Use, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing this site. The materials contained in this web site are protected by applicable copyright and trade mark law.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;h4&gt;Use License&lt;/h4&gt; &lt;ol&gt; &lt;li&gt;Permission is granted to temporarily download one copy of the materials (information or software) on SibLinks's web site for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not: &lt;ol&gt; &lt;li&gt; &lt;p&gt;modify or copy the materials;&lt;/p&gt; &lt;/li&gt; &lt;li&gt; &lt;p&gt;use the materials for any commercial purpose, or for any public display (commercial or non-commercial);&lt;/p&gt; &lt;/li&gt; &lt;li&gt; &lt;p&gt;attempt to decompile or reverse engineer any software contained on SibLinks's web site;&lt;/p&gt; &lt;/li&gt; &lt;li&gt; &lt;p&gt;remove any copyright or other proprietaty notations from the materials; or&lt;/p&gt; &lt;/li&gt; &lt;li&gt; &lt;p&gt;transfer the materials to another person or 'mirror' the materials on any other server.&lt;/p&gt; &lt;/li&gt; &lt;/ol&gt; &lt;/li&gt; &lt;li&gt;This license shall automatically terminate if you violate any of these restrictions and may be terminated by SibLinks at any time. Upon terminating your viewing of these materials or upon the termination of this license, you must destroy any downloaded materials in your possession whether in electronic of printed format. &lt;/li&gt; &lt;/ol&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;h4&gt;Limitations&lt;/h4&gt; &lt;p&gt;In no event shall SibLinks or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption,) arising out of the use or inability to use the materials on SibLinks's Internet site, even if SibLinks or a SibLinks authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;h4&gt;Revisions and Errata&lt;/h4&gt; &lt;p&gt;The materials appearing on SibLinks's web site could include technical, typographical, or photographic errors. SibLinks does not warrant that any of the materials on its web site are accurate, complete, or current. SibLinks may make changes to the materials contained on its web site at any time without notice. SibLinks does not, however, make any commitment to update the materials.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;h4&gt;Links&lt;/h4&gt; &lt;p&gt;SibLinks has not reviewed all of the sites linked to its Internet web site and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by SibLinks of the site. Use of any such linked web site is at the user's own risk.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;h4&gt;Site Terms of Use Modifications&lt;/h4&gt; &lt;p&gt;SibLinks may revise these terms of use for its web site at any time without notice. By using this web site you are agreeing to be bound by the then current version of these Terms and Conditions of Use.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;h4&gt;Governing Law&lt;/h4&gt; &lt;p&gt;Any claim relating to SibLinks's web site shall be governed by the laws of the State of California without regard to its conflict of law provisions.&lt;/p&gt; &lt;/div&gt; &lt;div class=&quot;term&quot;&gt; &lt;p&gt;General Terms and Conditions applicable to Use of a Web Site.&lt;/p&gt; &lt;/div&gt; &lt;/div&gt; &lt;/div&gt;"
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Terms of service".localized
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.loading = true
        startLoading()
        termsOfServiceHTML.convertHTML({ (attributedString) in
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SLTermsOfServiceViewController {

    // MARK: - Actions
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension SLTermsOfServiceViewController {
    
    override func hasContent() -> Bool {
        return !loading
    }
    
}
