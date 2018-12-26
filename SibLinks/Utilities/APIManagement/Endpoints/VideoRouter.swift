//
//  VideoRouter.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

enum VideoEndpoint {
    case GetVideos(subjectId: Int)
    case GetSuggestVideos(subjectId: Int)
    case GetRelatedVideos(subjectId: Int, admissionId: Int)
    case GetSubscriptionsVideo(userId: Int, subjectId: Int)
    case GetVideo(videoId: Int)
    case GetVideoAdmission(videoId: Int)
    case GetHistory(userId: Int)
    case GetFavourite(userId: Int)
    case GetSubscribers(userId: Int)
    case HistoryAdded(userId: Int, videoId: Int)
    case HistoryRemoved(userId: Int, videoId: Int)
    case FavouriteAdded(userId: Int, videoId: Int)
    case FavouriteRemoved(userId: Int, videoId: Int)
    case UpdateVideoView(videoId: Int)
    case UpdateViewArticle(articleId: Int)
    case UpdateVideoViewAdmission(videoId: Int)
    case GetComment(videoId: Int)
    case GetTotalComment(videoId: Int)
    case PostComment(userId: Int, authorId: Int, videoId: Int, content: String)
    case PostCommentAdmission(userId: Int, authorId: Int, videoId: Int, content: String)
    case GetCommentAdmission(videoId: Int)
    case GetVideoOfMentor(mentorId: Int)
    case GetCountVideoOfMentor(mentorId: Int)
    case GetPlaylistOfMentor(mentorId: Int)
    case GetCountPlaylistOfMentor(mentorId: Int)
    case GetVideoOfPlaylist(playlistId: Int)
    case RatingVideo(userId: Int, videoId: Int, rating: Int)
    case CheckRating(userId: Int, videoId: Int)
    case CheckFavourite(userId: Int, videoId: Int)
    case SearchVideo(subjectId: Int, search: String)
    case SearchPlaylist(subjectId: Int, search: String)
    case CheckCountFavourite(userId: Int)
    case GetVideoSubjects()
}

class VideoRouter: BaseRouter {
    var endpoint: VideoEndpoint
    
    init(endpoint: VideoEndpoint) {
        self.endpoint = endpoint
    }
    
    override var parameterEncoding: Moya.ParameterEncoding {
        switch endpoint {
        case .HistoryAdded(_), .FavouriteAdded(_), .FavouriteRemoved(_), .UpdateVideoView(_), .UpdateVideoViewAdmission(_), .UpdateViewArticle(_), .PostComment(_), .PostCommentAdmission(_), .RatingVideo(_), .CheckFavourite(_):
            return .JSON
        default:
            return .URLEncodedInURL
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetVideos(_):
            return "/siblinks/services/video/getNewestVideoBySubject"
        case .GetSuggestVideos(_):
            return "/siblinks/services/video/getNewestVideoBySubject"
        case .GetRelatedVideos(_):
            return "/siblinks/services/videodetail/getVideoByAdmissionId"
        case .GetSubscriptionsVideo(_):
            return "/siblinks/services/video/getVideoStudentSubscribe"
        case .GetVideo(let videoId):
            return "/siblinks/services/videodetail/getVideoDetailById/\(videoId)"
        case .GetVideoAdmission(let videoId):
            return "/siblinks/services/videodetail/getVideoAdmissionDetailById/\(videoId)"
        case .GetHistory(_):
            return "/siblinks/services/video/getHistoryVideosList"
        case .GetFavourite(let userId):
            return "/siblinks/services/favourite/allFavourite/\(userId)"
        case .GetSubscribers(_):
            return "/siblinks/services/student/getMentorSubscribed"
        case .HistoryAdded(_):
            return "/siblinks/services/videodetail/updateVideoHistory"
        case .HistoryRemoved(_):
            return "/siblinks/services/video/clearHistoryVideosList"
        case .FavouriteAdded(_):
            return "/siblinks/services/favourite/addfavourite"
        case .FavouriteRemoved(_):
            return "/siblinks/services/favourite/delFavourite"
        case .UpdateVideoView(_):
            return "/siblinks/services/video/updateViewVideo"
        case .UpdateVideoViewAdmission(_):
            return "/siblinks/services/videodetail/updateViewVideoAdmission"
        case .UpdateViewArticle(_):
            return "/siblinks/services/article/updateViewArticle"
        case .GetComment(let videoId):
            return "/siblinks/services/videodetail/getCommentVideoById/\(videoId)"
        case .GetTotalComment(let videoId):
            return "/siblinks/services/videodetail/getCommentVideoById/\(videoId)"
        case .PostComment(_):
            return "/siblinks/services/comments/addComment"
        case .PostCommentAdmission(_):
            return "/siblinks/services/comments/addCommentVideoAdmission"
        case .GetCommentAdmission(let videoId):
            return "/siblinks/services/videodetail/getCommentVideoAdmissionById/\(videoId)"
        case .GetVideoOfMentor(_):
            return "/siblinks/services/video/getVideos"
        case .GetCountVideoOfMentor(_):
            return "/siblinks/services/video/getVideos"
        case .GetPlaylistOfMentor(_):
            return "/siblinks/services/playlist/getPlaylist"
        case .GetCountPlaylistOfMentor(_):
            return "/siblinks/services/playlist/getPlaylist"
        case .GetVideoOfPlaylist(let playlistId):
            return "/siblinks/services/videodetail/getVideoByPlaylistId/\(playlistId)"
        case .RatingVideo(_):
            return "/siblinks/services/video/rateVideo"
        case .CheckRating(let userId, let videoId):
            return "/siblinks/services/video/getUserRatingVideo/\(userId)/\(videoId)"
        case .CheckFavourite(_):
            return "/siblinks/services/favourite/checkFavouriteVideo"
        case .SearchVideo(_):
            return "/siblinks/services/video/searchVideo"
        case .SearchPlaylist(_):
            return "/siblinks/services/video/searchVideo"
        case .CheckCountFavourite(let userId):
            return "/siblinks/services/favourite/countFavourite/\(userId)"
        case .GetVideoSubjects():
            return "/siblinks/services/video/getListCategorySubscription"
        }
    }
    
    override var method: Moya.Method {
        switch endpoint {
        case .HistoryAdded(_), .FavouriteAdded(_), .FavouriteRemoved(_), .UpdateVideoView(_), .UpdateViewArticle(_), .UpdateVideoViewAdmission(_), .PostComment(_), .PostCommentAdmission(_), .RatingVideo(_), .CheckFavourite(_):
            return .POST
        default:
            return .GET
        }
    }
    
    override var parameters: [String: AnyObject]? {
        switch endpoint {
        case .GetVideos(let subjectId):
            return ["subjectId": subjectId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetSuggestVideos(let subjectId):
            return ["subjectId": subjectId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetRelatedVideos(let subjectId, let admissionId):
            return ["subjectId": subjectId, "aId": admissionId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetSubscriptionsVideo(let userId, let subjectId):
            return ["userId": userId, "subjectId": (subjectId == -1) ? "" : "\(subjectId)", "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetSubscribers(let userId):
            return ["studentId": userId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetHistory(let userId):
            return ["uid": userId]
        case .HistoryAdded(let userId, let videoId):
            return ["request_data_type": "videodetail", "request_data_method": "updateVideoHistory", "request_data": ["uid": userId, "vid": videoId]]
        case .HistoryRemoved(let userId, let videoId):
            return ["uid": userId, "vid": (videoId == 0 ? "" : "\(videoId)")]
        case .FavouriteAdded(let userId, let videoId):
            return ["uid": userId, "vid": videoId]
        case .FavouriteRemoved(let userId, let videoId):
            return ["uid": userId, "vid": videoId]
        case .UpdateVideoView(let videoId):
            return ["request_data_type": "video", "request_data_method": "updateVideoWatched", "request_data": ["vid": videoId]]
        case .UpdateViewArticle(let articleId):
            return ["request_data_type": "addmission", "request_data_method": "rateVideoAddmission", "request_data_article": ["arId": articleId]]
        case .UpdateVideoViewAdmission(let videoId):
            return ["request_data_type": "video", "request_data_method": "updateVideoWatched", "request_data": ["vid": videoId]]
        case .PostComment(let userId, let authorId, let videoId, let content):
            return ["request_data_type": "comments", "request_data_method": "addComment", "request_data": ["authorID": authorId, "uid": userId, "vid": videoId, "content": content]]
        case .PostCommentAdmission(let userId, let authorId, let videoId, let content):
            return ["request_data_type": "comments", "request_data_method": "addComment", "request_data": ["authorID": authorId, "uid": userId, "vid": videoId, "content": content]]
        case .GetVideoOfMentor(let mentorId):
            return ["uid": mentorId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetCountVideoOfMentor(let mentorId):
            return ["uid": mentorId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetPlaylistOfMentor(let mentorId):
            return ["userid": mentorId, "offset": skip ?? 0, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER]
        case .GetCountPlaylistOfMentor(let mentorId):
            return ["userid": mentorId, "offset": skip ?? 0, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER]
        case .RatingVideo(let userId, let videoId, let rating):
            return ["request_data_type": "video", "request_data_method": "rateVideo", "request_data":["uid": userId, "vid": videoId, "rating": rating]]
        case .CheckFavourite(let userId, let videoId):
            return ["uid": userId, "vid": videoId]
        case .SearchVideo(let subjectId, let search):
            var subjectIdString = ""
            if subjectId >= 0 {
                subjectIdString = "\(subjectId)"
            }
            return ["subjectId": subjectIdString, "keyword": search, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0, "type": "video"]
        case .SearchPlaylist(let subjectId, let search):
            var subjectIdString = ""
            if subjectId >= 0 {
                subjectIdString = "\(subjectId)"
            }
            return ["subjectId": subjectIdString, "keyword": search, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0, "type": "playlist"]
        default:
            return nil
        }
    }
    
    override var sampleData: NSData {
        return NSData()
    }
    
    override var multipartBody: [MultipartFormData]? {
        return nil
    }
    
    override func parseResponse(json: JSON) -> AnyObject? {
//        logger.info("JSON - VideoRouter: \(json)")
        switch endpoint {
        case .HistoryAdded(_):
            let result = json["request_data_result"].stringValue
            var status = false
            if result == "Done" {
                status = true
            }
            
            return status
        case .HistoryRemoved(_):
            return json["request_data_result"].boolValue
        case .FavouriteAdded(_):
            let result = json["request_data_result"].stringValue
            var status = false
            if result == "Favourite add successful" {
                status = true
            }
            
            return status
        case .FavouriteRemoved(_):
            // Delete favourite successful
            let result = json["request_data_result"].stringValue
            var status = false
            if result == " Delete favourite successful" {
                status = true
            }
            
            return status
        case .RatingVideo(_):
            return nil
        case .CheckRating(_):
            let rate = [SLRate](byJSON: json["request_data_result"])
            var status = false
            if rate.count > 0 {
                status = true
            }
            
            return status
        case .CheckFavourite(_):
            let result = json["request_data_result"].stringValue
            var status = false
            if result == "true" {
                status = true
            }
            
            return status
        case .GetSubscribers(_):
            return [SLMentor](byJSON: json["request_data_result"])
        case .GetComment(_):
            return [SLComment](byJSON: json["request_data_result"])
        case .GetTotalComment(_):
            let result = json["count"].intValue
            return result
        case .GetCommentAdmission(_):
            return [SLComment](byJSON: json["request_data_result"])
        case .PostComment(_):
            return nil
        case .PostCommentAdmission(_):
            return nil
        case .GetCountVideoOfMentor(_):
            let result = json["count"].intValue
            return result
        case .GetPlaylistOfMentor(_):
            return [SLPlaylist](byJSON: json["request_data_result"])
        case .GetCountPlaylistOfMentor(_):
            let result = json["count"].intValue
            return result
        case .SearchPlaylist(_):
            return [SLPlaylist](byJSON: json["request_data_result"])
        case .CheckCountFavourite(_):
            let subscriber = json["request_data_result"][0]["count(*)"]
            return subscriber.intValue
        case .GetVideoSubjects():
            return [SLCategory](byJSON: json["request_data_result"])
        default:
            return [SLVideo](byJSON: json["request_data_result"])
        }
    }
}
