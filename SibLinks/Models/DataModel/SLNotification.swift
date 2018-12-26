//
//  SLNotification.swift
//  SibLinks
//
//  Created by Jana on 10/31/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLNotification: DataModel {
    
    var senderId: Int?
    var receiverId: Int?
    var type: NotificationDataType = .Unknown
    var title: String?
    var notification: String?
    var subjectId: Int?
    var linkToId: Int?
    var status: Bool?
    var username: String?
    var firstName: String?
    var lastName: String?
    var imageUrl: String?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["id"].exists() {
            objectId = json["id"].intValue
        }
        
        if json["senderId"].exists() {
            senderId = json["senderId"].intValue
        }
        
        if json["receiverId"].exists() {
            senderId = json["receiverId"].intValue
        }
        
        if json["type"].exists() {
            let value = json["type"].stringValue
            type = NotificationDataType(rawValue: value.toInt()) ?? .Unknown
        }
        
        if json["title"].exists() {
            title = json["title"].stringValue
        }
        
        if json["notification"].exists() {
            notification = json["notification"].stringValue
        }
        
        if json["subjectId"].exists() {
            subjectId = json["subjectId"].intValue
        }
        
        if json["linkToId"].exists() {
            linkToId = json["linkToId"].intValue
        }
        
        if json["status"].exists() {
            let value = json["status"].stringValue
            if (value == "Y") {
                status = true
            } else {
                status = false
            }
        }
        
        if json["firstName"].exists() {
            firstName = json["firstName"].stringValue
        }
        
        if json["lastName"].exists() {
            lastName = json["lastName"].stringValue
        }
        
        if json["userName"].exists() {
            username = json["userName"].stringValue
        }
        
        if json["imageUrl"].exists() {
            imageUrl = json["imageUrl"].stringValue
        }
        
        if (json["timestamp"]).exists() {
            createdAt = json["timestamp"].stringValue.toDate()
        }
    }
    
    func name() -> String {
        var fullname = ""
        if let firstname = firstName {
            fullname += firstname
        }
        
        if let lastname = lastName {
            fullname += fullname.characters.count > 0 ? " " + lastname : lastname
        }
        
        if fullname.characters.count == 0 {
            if let username = username {
                var name = username
                if username.isEmail() {
                    name = username.getUsernameFromEmail()
                }
                fullname = name
            }
        }
        
        return fullname
    }
    
}
