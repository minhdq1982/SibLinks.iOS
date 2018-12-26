//
//  SLLocalDataManager.swift
//  SibLinks
//
//  Created by Tuan Pham Hai  on 10/1/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit

class SLLocalDataManager: NSObject {
    static let sharedInstance = SLLocalDataManager()
    
    lazy var localQuestions = [SLSaveQuestion]()
    
    override init() {
        super.init()
        localQuestions += self.unarchiveQuestions()
    }
    
    // MARK: Once user did change login account, this function must be called
    func refreshDataWhenSwitchUser() {
        localQuestions.removeAll()
        localQuestions += self.unarchiveQuestions()
    }
    
    // MARK: Get local questions of current logged in user, then display on top of ask list
    func getLocalQuestions() -> [SLQuestion] {
        var questions = [SLQuestion]()
        for saveQuestion in localQuestions {
            questions.append(saveQuestion.convertToQuestion())
        }
        return questions
    }
    
    // MARK: Manage local question info {
    func generateLocalQuestionId() -> Int {
        var maxId: Int = 0;
        for saveQuestion in localQuestions {
            if saveQuestion.localId > maxId {
                maxId = saveQuestion.localId!
            }
        }
        return (maxId + 1)
    }
    
    //  File index of question in local question list
    func getIndexOfQuestion(question:SLQuestion) -> Int {
        var counter = 0
        for aQuestion in localQuestions {
            if aQuestion.localId == question.localId {
                return counter;
            }
            counter += 1;
        }
        return -1
    }
    
    func isLocalQuestionExisted(question:SLQuestion) -> Bool {
        for aQuestion in localQuestions {
            if aQuestion.localId == question.localId {
                return true;
            }
        }
        return false
    }
    
    //  Add one more question to local at first, then try to post the question
    func saveQuestion (question: SLQuestion, images:[UIImage]){
        if !self.isLocalQuestionExisted(question) {
            //  Save all images at first
            question.localImageNames = self.saveQuestionPhotos(question, images: images)
            //  Then save question info
            let saveQuestion = SLSaveQuestion(question: question)
            localQuestions.append(saveQuestion);
            
        } else{
            self.updateQuestion(question, images: images)
        }
        
        self.archiveQuestions(localQuestions)
    }
    
    //  Remove local question in case of: the post question get failed OR user manualy delete question
    func removeQuestion(question: SLQuestion) -> Bool{
        let index = self.getIndexOfQuestion(question)
        if index >= 0 {
            //  Remove question
            localQuestions.removeAtIndex(index)
            //  Delete all photo of question also
            self.deleteAllPhotosOfQuestion(question)
            //  Save remaining questions
            self.archiveQuestions(localQuestions)
            return true
        } else{
            return false
        }
    }
    
    //  Update question while editing it
    func updateQuestion(question:SLQuestion, images:[UIImage]) -> Bool {
        
        if question.hasEditingImage() {
            //  Firstly remove all old image
            self.deleteAllPhotosOfQuestion(question)
            
            //  Then update new images list
            question.localImageNames = self.saveQuestionPhotos(question, images: images)
        }
        
        //  Then update info of question
        let saveQuestion = SLSaveQuestion(question: question)
        
        var counter = 0
        for aQuestion in localQuestions {
            if aQuestion.localId == question.localId {
                //  Need to tranfer all information to save to local
                localQuestions.removeAtIndex(counter)
                localQuestions.insert(saveQuestion, atIndex: counter)
                break;
            }
            counter += 1;
        }
        self.archiveQuestions(localQuestions)
        
        return true
    }
    // MARK: }
}

extension SLLocalDataManager {
    
    func uploadQuestion(question:SLQuestion, success: (() -> Void)?, failure: ((NSError?) -> Void)?) {
        if question.sending {
            return
        }
        
        //  Get all need upload photos
        let questionImages = self.getQuestionPhotos(question)
        
        //  Post question
        if question.objectId > 0 {
            let imagePath = question.questionImages?.joinWithSeparator(";")
            let editedImagePath = question.editingImages?.joinWithSeparator(";")
            var editedImages = [UIImage]()
            for image in questionImages {
                if let editedImagesPath = question.editingImages {
                    if let imageIdentifier = image.accessibilityIdentifier {
                        if !imageIdentifier.containsString("photo_") {
                            for imagePath in editedImagesPath {
                                let lastImageName = NSURL(fileURLWithPath: imagePath).lastPathComponent!
                                if lastImageName == imageIdentifier {
                                    editedImages.append(image)
                                }
                            }
                        } else {
                            editedImages.append(image)
                        }
                    } else {
                        editedImages.append(image)
                    }
                } else {
                    editedImages.append(image)
                }
            }
            
            question.sending = true
            AskQuestionRouter(endpoint: AskQuestionEndpoint.EditQuestion(questionId: question.objectId!, userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, subjectId: (question.category?.objectId)!, content: question.title!,imagePath: imagePath ?? "", editedImagePath: editedImagePath ?? "", images: editedImages)).request(completion: { (result) in
                question.sending = false
                switch result {
                case .Ok:
                    self.removeQuestion(question)
                    SLTrackingEvent.sharedInstance.sendEditAQuestionEvent(SLTrackingEvent.kSLAskAQuestionScreen)
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.POST_QUESTION_CHANGE, object: true)
                    success?()
                default:
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.POST_QUESTION_CHANGE, object: nil)
                    failure?(nil)
                }
            })
        } else {
            question.sending = true
            AskQuestionRouter(endpoint: AskQuestionEndpoint.PostQuestion(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, subjectId: (question.category?.objectId)!, content: question.title!, images: questionImages)).request(completion: { (result) in
                question.sending = false
                switch result {
                case .Success(let object):
                    self.removeQuestion(question)
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.POST_QUESTION_CHANGE, object: object)
                    success?()
                default:
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.POST_QUESTION_CHANGE, object: nil)
                    failure?(nil)
                }
            })
        }
    }
    
    func uploadAllPendingQuestions(questions:[SLQuestion]) {
        for question in questions {
            self.uploadQuestion(question, success: nil, failure: nil)
        }
    }
}

extension SLLocalDataManager {
    func generateLocalImageName(question:SLQuestion, index:Int) -> String {
//        var imageName = "photo_\(index).jpg"
//        
//        let isLiveQuestion = question.isLiveQuestion()
//        
        //  If question already
//        if isLiveQuestion == true, let questionImages = question.questionImages {
//            if index - 1 < questionImages.count {
//                //  Using url as name of photo in local to upload later
//                let imagePath = questionImages[index - 1]
//                imageName = NSURL(fileURLWithPath: imagePath).lastPathComponent!
//            }
//        }
        
        return "photo_\(index).jpg"
    }
    
    // MARK: Manage photos of question
    private func saveQuestionPhotos(question:SLQuestion, images:[UIImage]) -> [String] {
        
        var names = [String]()
        var counter = 0
        let questionFolder = self.getQuestionFolder(question)

        for image in images{
            var imageName = self.generateLocalImageName(question, index: (counter + 1))//"photo_\(counter + 1).jpg"
            if let imageIdentifier = image.accessibilityIdentifier {
                imageName = NSURL(fileURLWithPath: imageIdentifier).lastPathComponent!
            }
            
            let imagePath = questionFolder.stringByAppendingString("/\(imageName)")
            if let dataImage = UIImageJPEGRepresentation(image,1.0) {
                dataImage.writeToFile(imagePath, atomically: true)
            }
            names.append(imageName)
            
            counter += 1;
        }
        
        //  Return all photo name of question
        return names
    }
    
    func deleteFileAtPaths(paths:[String]) -> Bool {
        var retValue = true
        for path in paths {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                } catch {
                    retValue = false;
                    break;
                }
            }
        }
        
        return retValue
    }
    
    func deleteAnPhotoOfQuestion(question:SLQuestion, localImageName:String) -> Bool {
        let questionFolderPath = self.getQuestionFolder(question)
        let localImageFilePath = questionFolderPath.stringByAppendingString("/\(localImageName)")
        return self.deleteFileAtPaths([localImageFilePath])
    }
    
    func deleteAllPhotosOfQuestion(question:SLQuestion) -> Bool {
        let questionFolderPath = self.getQuestionFolder(question)
        return self.deleteFileAtPaths([questionFolderPath])
    }
    
    func getQuestionPhotos(question:SLQuestion) -> [UIImage] {
        var images = [UIImage]()
        
        let questionFolder = self.getQuestionFolder(question)
        
        for imageName in question.localImageNames! {
            let imagePath = questionFolder.stringByAppendingString("/\(imageName)")
            if NSFileManager.defaultManager().fileExistsAtPath(imagePath) {
                let image = UIImage(contentsOfFile: imagePath)
                image?.accessibilityIdentifier = imageName
                if image != nil {
                   images.append(image!)
                }
            }
        }
        
        print("images: \(images)")
        return images
    }
}

extension SLLocalDataManager {
    // MARK: Save and Load local list of {SLSaveQuestion}
    
    func archiveQuestions(questions: [SLSaveQuestion]) {
        if questions.count > 0 {
            let encodeQuestions = NSKeyedArchiver.archivedDataWithRootObject(questions)
            NSUserDefaults.standardUserDefaults().setObject(encodeQuestions, forKey:self.getLocalQuestionKey())
        } else{
            NSUserDefaults.standardUserDefaults().removeObjectForKey(self.getLocalQuestionKey())
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func unarchiveQuestions() -> [SLSaveQuestion] {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(self.getLocalQuestionKey()) {
            if let objects = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as? [SLSaveQuestion] {
                
                //  Log all saved questions
                for saveQuestion in objects {
                    saveQuestion.printQuestion()
                }
                
                return objects
            }
        }
        
        return [SLSaveQuestion]()
    }
}

extension SLLocalDataManager {
    
    func getLocalQuestionKey() -> String {
        let currentUser = SLUserViewModel.sharedInstance.currentUser;
        let key = "Pending_Question_\(currentUser!.userId!)"
        return key
    }
    
    func getLocalQuestionFilePathOfUser(user:SLSaveUser) -> String {
        
        let user = SLUserViewModel.sharedInstance.currentUser;
        let fileName = "Pending_Question_\(user!.userId!).txt"
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let writePath = documents.stringByAppendingString("/\(fileName)")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(writePath) {
            //  Create file at path
            let success = NSFileManager.defaultManager().createFileAtPath(writePath, contents: nil, attributes: nil);
            if success {
                print("Success to create file at path : \(writePath)");
            }
        }
        
        return writePath
    }
    
    func getQuestionFolder(question:SLQuestion) -> String {
        
        let user = SLUserViewModel.sharedInstance.currentUser;
        let userFolderName = "Private_user_\(user!.userId!)"
        let questionFolderName = "Question_\(question.localId!)"
        
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let userFolderPath = documents.stringByAppendingString("/\(userFolderName)")
        
        print("userFolderPath: \(userFolderPath)")
        
        //  Create user folder if need
        if !NSFileManager.defaultManager().fileExistsAtPath(userFolderPath) {
            //  Create user folder at path
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(userFolderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Could not create user folder")
            }
        }
        
        let questionFolderPath = userFolderPath.stringByAppendingString("/\(questionFolderName)")
        if !NSFileManager.defaultManager().fileExistsAtPath(questionFolderPath) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(questionFolderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Could not create local folder question")
            }
        }
        
        return questionFolderPath
    }
}
