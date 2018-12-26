//
//  SLQuestion.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

enum QuestionType {
    case NotAnswered
    case Answered
    case Reviewing
    case Waiting
}

class SLQuestion: DataModel {
    
    var title: String?
    var numberOfViews: Int?
    var thumbnailImageName: String?
    var student: SLUser?
    var answers: [SLAnswer]?
    var category: SLCategory?
    var questionImages: [String]?
    var numberOfReplies: Int?
    var localId: Int?
    var editingImages: [String]?
    var localImageNames: [String]?
    var questionType: QuestionType?
    var content: String?
    var sending = false
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["PID"].exists() {
            objectId = json["PID"].intValue
        } else if json["pid"].exists() {
            objectId = json["pid"].intValue
        }
        
        if json["CONTENT"].exists() {
            title = json["CONTENT"].stringValue
        } else if json["content"].exists() {
            title = json["content"].stringValue
        }
        
        if json["NUMVIEWS"].exists() {
            numberOfViews = json["NUMVIEWS"].intValue
        } else if json["numViews"].exists() {
            numberOfViews = json["numViews"].intValue
        }
        
        if json["IMAGEPATH"].exists() {
            let questionImages = json["IMAGEPATH"].stringValue.componentsSeparatedByString(";")
            self.questionImages = questionImages
            
            self.questionImages = self.questionImages?.filter { $0 != "" }
        } else if json["imagePath"].exists() {
            let questionImages = json["imagePath"].stringValue.componentsSeparatedByString(";")
            self.questionImages = questionImages
            
            self.questionImages = self.questionImages?.filter { $0 != "" }
        }
        
        student = SLUser(byJSON: json)
        category = SLCategory(byJSON: json)
        
        if json["TIMESTAMP"].exists() {
            updatedAt = json["TIMESTAMP"].stringValue.toDate()
            createdAt = json["TIMESTAMP"].stringValue.toDate()
        }
        
        if json["NUMREPLIES"].exists() {
            numberOfReplies = json["NUMREPLIES"].intValue
        } else if json["numReplies"].exists() {
            numberOfReplies = json["numReplies"].intValue
        }
        
    }
    
    func hasAnswer() -> Bool {
        return numberOfReplies > 0
    }
    
    func isLiveQuestion() -> Bool {
        return objectId > 0
    }
    
    func isLocalQuestion() -> Bool {
        return localId > 0
    }
    
    func hasEditingImage() -> Bool {
        return editingImages?.count > 0
    }
}

class SLSaveQuestion: NSObject, NSCoding {
    
    var objectId: Int?
    var title: String?
    var numberOfViews: Int?
    var thumbnailImageName: String?
    //SLUser?
    var studentId:  Int?
    //SLCategory?
    var categoryId: Int?
    var categoryName: String?
    var questionImages: [String]?
    var numberOfReplies: Int?
    var localId: Int?
    var editingImages : [String]?
    var localImageNames : [String]?
    
    override init() {}
    
    convenience init(question: SLQuestion) {
        self.init()
        
        self.objectId = question.objectId
        self.title = question.title
        self.numberOfViews = 0
        self.thumbnailImageName = "Thumnail.png"
        self.studentId = question.student?.objectId
        self.categoryId = question.category?.objectId
        self.categoryName = question.category?.subject
        self.questionImages = question.questionImages;
        self.numberOfReplies = 0
        self.localId = question.localId
        self.editingImages = question.editingImages
        self.localImageNames = question.localImageNames
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        self.objectId = Int(decoder.decodeInt32ForKey("objectId"))
        self.title = decoder.decodeObjectForKey("title") as? String
        self.numberOfViews = Int(decoder.decodeInt32ForKey("numberOfViews"))
        self.thumbnailImageName = decoder.decodeObjectForKey("thumbnailImageName") as? String
        self.studentId = Int(decoder.decodeInt32ForKey("studentId"))
        self.categoryId = Int(decoder.decodeInt32ForKey("categoryId"))
        self.categoryName = decoder.decodeObjectForKey("categoryName") as? String
        self.questionImages = decoder.decodeObjectForKey("questionImages") as? [String]
        self.numberOfReplies = Int(decoder.decodeInt32ForKey("numberOfReplies"))
        self.localId = Int(decoder.decodeInt32ForKey("localId"))
        self.editingImages = decoder.decodeObjectForKey("editingImages") as? [String]
        self.localImageNames = decoder.decodeObjectForKey("localImageNames") as? [String]
    }
    
    func encodeWithCoder(coder: NSCoder) {
        if let objectId = self.objectId { coder.encodeInt(Int32(objectId), forKey: "objectId") }
        if let title = self.title { coder.encodeObject(title, forKey: "title") }
        if let numberOfViews = self.numberOfViews { coder.encodeInt(Int32(numberOfViews), forKey: "numberOfViews") }
        if let thumbnailImageName = self.thumbnailImageName { coder.encodeObject(thumbnailImageName, forKey: "thumbnailImageName") }
        if let studentId = self.studentId { coder.encodeInt(Int32(studentId), forKey: "studentId") }
        if let categoryId = self.categoryId { coder.encodeInt(Int32(categoryId), forKey: "categoryId") }
        if let categoryName = self.categoryName { coder.encodeObject(categoryName, forKey: "categoryName") }
        if let questionImages = self.questionImages { coder.encodeObject(questionImages, forKey: "questionImages") }
        if let numberOfReplies = self.numberOfViews { coder.encodeInt(Int32(numberOfReplies), forKey: "numberOfReplies") }
        if let localId = self.localId { coder.encodeInt(Int32(localId), forKey: "localId") }
        if let editingImages = self.editingImages { coder.encodeObject(editingImages, forKey: "editingImages") }
        if let localImageNames = self.localImageNames { coder.encodeObject(localImageNames, forKey: "localImageNames") }
    }
    
    func convertToQuestion() -> SLQuestion {
        let question = SLQuestion()
        question.objectId = self.objectId
        question.title = self.title
        question.numberOfViews = self.numberOfViews
        question.thumbnailImageName = self.thumbnailImageName
        
        // Will use default login user to upload question
        question.category = SLCategory()
        question.category?.objectId = self.categoryId
        question.category?.subject = self.categoryName
        question.questionImages = self.questionImages
        question.numberOfReplies = self.numberOfReplies
        question.localId = self.localId
        question.editingImages = self.editingImages
        question.localImageNames = self.localImageNames
        
        return question
    }
    
    func printQuestion() {
        
        let titleStr = (self.title != nil) ? self.title! : ""
        let categoryNameStr = (self.categoryName != nil) ? self.categoryName! : ""
        
        print("Question: \(titleStr)\n userId: \(self.studentId!) \n CategoryId: \(self.categoryId!) \n Category name: \(categoryNameStr) \n Local image names: \(self.localImageNames) \n Local question ID: \(self.localId!)")
    }
}
