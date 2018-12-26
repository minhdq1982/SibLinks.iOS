//
//  SLUser.swift
//  SibLinks
//
//  Created by Jana on 9/19/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLUser: DataModel {
    
    var email: String?
    var firstname: String?
    var lastname: String?
    var school: String?
    var gender: String?
    var birthday: NSDate?
    var defaultSubjectId: String?
    var aboutMe: String?
    var status: String?
    var userType: String?
    var imageUrl: String?
    var numberOfSubscriber: Int?
    var numberOfEssay: Int?
    var numberOfQuestion: Int?
    var uploadAvatar: UIImage?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["userid"].exists() {
            objectId = json["userid"].intValue
        }
        
        if json["username"].exists() {
            email = json["username"].stringValue
        } else if json["userName"].exists() {
            email = json["userName"].stringValue
        }
        
        if json["firstname"].exists() {
            firstname = json["firstname"].stringValue
        } else if json["userName"].exists() {
            firstname = json["firstName"].stringValue
        }
        
        if json["lastname"].exists() {
            lastname = json["lastname"].stringValue
        } else if json["lastName"].exists() {
            lastname = json["lastName"].stringValue
        }
        
        if json["imageUrl"].exists() {
            imageUrl = json["imageUrl"].stringValue
        }
        
        if json["status"].exists() {
            status = json["status"].stringValue
        }
        
        if json["school"].exists() {
            school = json["school"].stringValue
        }
        
        if json["gender"].exists() {
            if json["gender"].stringValue.isEmpty {
                gender = nil
            } else {
                gender = json["gender"].stringValue
            }
        }
        
        if json["defaultSubjectId"].exists() {
            defaultSubjectId = json["defaultSubjectId"].stringValue
        }
        
        if json["bio"].exists() {
            aboutMe = json["bio"].stringValue
        }
        
        if json["count_subscribe"].exists() {
            numberOfSubscriber = json["count_subscribe"].intValue
        }
        
        if json["count_essay"].exists() {
            numberOfEssay = json["count_essay"].intValue
        }
        
        if json["count_question"].exists() {
            numberOfQuestion = json["count_question"].intValue
        }
        
        if json["birthDay"].exists() {
            if json["birthDay"].stringValue.isEmpty {
                birthday = nil
            } else {
                birthday = json["birthDay"].stringValue.toDate()
            }
        }
    }
    
    func name() -> String {
        var fullname = ""
        if let firstname = firstname {
            fullname += firstname
        }
        
        if let lastname = lastname {
            fullname += fullname.characters.count > 0 ? " " + lastname : lastname
        }
        
        if fullname.characters.count == 0 {
            if let username = email {
                var name = username
                if username.isEmail() {
                    name = username.getUsernameFromEmail()
                }
                fullname = name
            }
        }
        
        return fullname
    }
    
    func birthdayAndGender() -> String {
        var birthdayAndGender = ""
        
        if let birthday = birthday {
            birthdayAndGender += birthDateFormatter.stringFromDate(birthday)
        }
        
        if let gender = gender {
            var genderString = "Decline to state"
            if gender == "M" {
                genderString = "Male"
            } else if gender == "F" {
                genderString = "Female"
            }
            
            birthdayAndGender += birthdayAndGender.characters.count > 0 ? " - " + genderString : genderString
        }
        
        return birthdayAndGender
    }
    
    func defaultSubjectIdToString(string: String) -> String {
        var categoriesStringParser = [String]()
        let categoriesStringArray = string.componentsSeparatedByString(",")
        let categories = Constants.appDelegate().categories
        for index in 0 ..< categoriesStringArray.count {
            for category in categories {
                if category.objectId == categoriesStringArray[index].toInt() {
                    categoriesStringParser.append(category.subject ?? "")
                }
            }
        }
        
        var fullCategories = ""
        for index in 0 ..< categoriesStringParser.count {
            fullCategories += ", \(categoriesStringParser[index])"
        }
        return fullCategories
    }
    
    func favoritesSubject() -> String {
        let array = defaultSubjectId?.componentsSeparatedByString(",")
        
        if let elements = array {
            var favorites = ""
            for favorite in Constants.appDelegate().categories {
                if let isForum = favorite.isForum {
                    if isForum == true {
                        if let favoriteId = favorite.objectId {
                            let favoriteIdString = "\(favoriteId)"
                            if elements.contains(favoriteIdString) {
                                if favorites.isEmpty {
                                    favorites += "\(favoriteId)"
                                } else {
                                    favorites += ",\(favoriteId)"
                                }
                            }
                        }
                    }
                }
            }
            
            return favorites
        }
        
        return ""
    }
    
}

class SLSaveUser: NSObject, NSCoding {
    
    var userId: Int?
    var email: String?
    var firstname: String?
    var lastname: String?
    var school: String?
    var gender: String?
    var birthday: NSDate?
    var defaultSubjectId: String?
    var aboutMe: String?
    var status: String?
    var userType: String?
    var imageUrl: String?
    
    override init() {}
    
    convenience init(user: SLUser) {
        self.init()
        
        self.userId = user.objectId
        self.email = user.email
        self.firstname = user.firstname
        self.lastname = user.lastname
        self.school = user.school
        self.gender = user.gender
        self.birthday = user.birthday
        self.defaultSubjectId = user.defaultSubjectId
        self.aboutMe = user.aboutMe
        self.status = user.status
        self.userType = user.userType
        self.imageUrl = user.imageUrl
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        self.userId = Int(decoder.decodeIntForKey("userid"))
        self.email = decoder.decodeObjectForKey("email") as? String
        self.firstname = decoder.decodeObjectForKey("firstname") as? String
        self.lastname = decoder.decodeObjectForKey("lastname") as? String
        self.school = decoder.decodeObjectForKey("school") as? String
        self.gender = decoder.decodeObjectForKey("gender") as? String
        self.birthday = decoder.decodeObjectForKey("birthday") as? NSDate
        self.defaultSubjectId = decoder.decodeObjectForKey("defaultSubjectId") as? String
        self.aboutMe = decoder.decodeObjectForKey("aboutMe") as? String
        self.status = decoder.decodeObjectForKey("status") as? String
        self.userType = decoder.decodeObjectForKey("userType") as? String
        self.imageUrl = decoder.decodeObjectForKey("imageUrl") as? String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        if let userId = self.userId { coder.encodeInt(Int32(userId), forKey: "userid") }
        if let email = self.email { coder.encodeObject(email, forKey: "email") }
        if let firstname = self.firstname { coder.encodeObject(firstname, forKey: "firstname") }
        if let lastname = self.lastname { coder.encodeObject(lastname, forKey: "lastname") }
        if let school = self.school { coder.encodeObject(school, forKey: "school") }
        if let gender = self.gender { coder.encodeObject(gender, forKey: "gender") }
        if let birthday = self.birthday { coder.encodeObject(birthday, forKey: "birthday") }
        if let defaultSubjectId = self.defaultSubjectId { coder.encodeObject(defaultSubjectId, forKey: "defaultSubjectId") }
        if let aboutMe = self.aboutMe { coder.encodeObject(aboutMe, forKey: "aboutMe") }
        if let status = self.status { coder.encodeObject(status, forKey: "status") }
        if let userType = self.userType { coder.encodeObject(userType, forKey: "userType") }
        if let imageUrl = self.imageUrl { coder.encodeObject(imageUrl, forKey: "imageUrl") }
    }
    
    func name() -> String {
        var fullname = ""
        if let firstname = firstname {
            fullname += firstname
        }
        
        if let lastname = lastname {
            fullname += fullname.characters.count > 0 ? " " + lastname : lastname
        }
        
        if fullname.characters.count == 0 {
            if let username = email {
                var name = username
                if username.isEmail() {
                    name = username.getUsernameFromEmail()
                }
                fullname = name
            }
        }
        
        return fullname
    }
    
    func favoritesSubject() -> String {
        var favorites = ""
        for favorite in Constants.appDelegate().categories {
            if let isForum = favorite.isForum {
                if isForum == true {
                    if favorites.isEmpty {
                        favorites += "\(favorite.objectId)"
                    } else {
                        favorites += ",\(favorite.objectId)"
                    }
                }
            }
        }
        
        return favorites
    }
}
