//
//  SLEssayInfoTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

protocol SLEssayInfoTableViewCellDelegate {
    func chooseUniversityAction(button: AnyObject, currentCell: SLEssayInfoTableViewCell)
    func chooseFalcultyAction(button: AnyObject, currentCell: SLEssayInfoTableViewCell)
}

class SLEssayInfoTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var essayTitleTextField: AnimatableTextField!
    @IBOutlet weak var universityTextField: AnimatableTextField!
    @IBOutlet weak var fucultyTextField: AnimatableTextField!
    @IBOutlet weak var essayContentTextView: SLPlaceholderTextView!
    @IBOutlet weak var chooseUniversityButton: UIButton!
    @IBOutlet weak var chooseFalcultyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.essayTitleTextField.delegate = self
    }
    
}

extension SLEssayInfoTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLEssayInfoTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        if let essay = data as? SLEssay {
            essayTitleTextField.text = essay.title ?? ""
            essayContentTextView.text = essay.desc ?? ""
            if let schoolName = essay.school?.name {
                universityTextField.text = schoolName
            } else {
                universityTextField.text = ""
            }
            
            if let subjectName = essay.major?.name {
                fucultyTextField.text = subjectName
            } else {
                fucultyTextField.text = ""
            }
        } else {
            essayTitleTextField.text = ""
            essayContentTextView.text = ""
            universityTextField.text = ""
        }
    }
    
}

extension SLEssayInfoTableViewCell: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.essayTitleTextField) {
            self.essayTitleTextField.resignFirstResponder()
        }
        return true
    }
    
}

extension SLEssayInfoTableViewCell {
    
    // MARK: - Public methods
    
    func setUniversity(string: String) {
        self.universityTextField.text = string
    }
    
    func setFuculty(string: String) {
        self.fucultyTextField.text = string
    }
    
}

extension SLEssayInfoTableViewCell {
    
    // MARK: - Actions
    
    @IBAction func chooseUniversityAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLEssayInfoTableViewCellDelegate else {
            return
        }
        
        delegate.chooseUniversityAction(sender, currentCell: self)
    }
    
    @IBAction func chooseFalcultyAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLEssayInfoTableViewCellDelegate else {
            return
        }
        
        delegate.chooseFalcultyAction(sender, currentCell: self)
    }
    
}
