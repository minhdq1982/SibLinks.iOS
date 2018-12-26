//
//  SLEssayDownloadTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLEssayDownloadTableViewCell: SLBaseTableViewCell {

    var reviewed = false
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var downloadButton: LoadingButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadButton.setActivityIndicatorStyle(.Gray, state: .Normal)
    }
    
    @IBAction func previewEssay(sender: LoadingButton) {
        if let indexPath = indexPath, let viewController = delegate as? SLEssayDetailsViewController {
            viewController.previewEssay(sender, indexPath: indexPath)
        } else if let indexPath = indexPath, let viewController = delegate as? SLUploadEssayViewController {
            viewController.previewEssay(sender, indexPath: indexPath)
        }
    }
}

extension SLEssayDownloadTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLEssayDownloadTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        if let essay = data as? SLEssay {
            if reviewed {
                self.fileNameLabel.text = essay.fileReviewedName ?? ""
                if let fileSize = essay.fileReviewedSize {
                    self.fileSizeLabel.text = NSByteCountFormatter.stringFromByteCount(Int64(fileSize), countStyle: .Decimal)
                } else {
                    self.fileSizeLabel.text = ""
                }
                
                if let mentorId = essay.mentor?.objectId, let essayId = essay.objectId, let essayName = essay.fileReviewedName, let fileSize = essay.fileReviewedSize {
                    let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                    let fileName = "essay_\(mentorId)_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                    if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                        self.downloadButton.setTitle("  Preview", forState: .Normal)
                        self.downloadButton.setImage(UIImage(named: "preview")!, state: .Normal)
                    } else {
                        self.downloadButton.setTitle("  Download", forState: .Normal)
                        self.downloadButton.setImage(UIImage(named: "download")!, state: .Normal)
                    }
                }
            } else {
                self.fileNameLabel.text = essay.fileName ?? ""
                if let fileSize = essay.fileSize {
                    self.fileSizeLabel.text = NSByteCountFormatter.stringFromByteCount(Int64(fileSize), countStyle: .Decimal)
                } else {
                    self.fileSizeLabel.text = ""
                }
                
                if let essayId = essay.objectId, let essayName = essay.fileName, let fileSize = essay.fileSize {
                    let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                    let fileName = "essay_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                    if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                        self.downloadButton.setTitle("  Preview", forState: .Normal)
                        self.downloadButton.setImage(UIImage(named: "preview")!, state: .Normal)
                    } else {
                        self.downloadButton.setTitle("  Download", forState: .Normal)
                        self.downloadButton.setImage(UIImage(named: "download")!, state: .Normal)
                    }
                }
            }
        } else {
            self.fileNameLabel.text = ""
            self.fileSizeLabel.text = ""
            self.downloadButton.setImage(UIImage(), state: .Normal)
            self.downloadButton.setTitle("Unknown", forState: .Normal)
        }
    }
    
}
