//
//  SLVideoViewModel.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Moya

class SLVideoViewModel: SLBaseViewModel {
    static let sharedInstance = SLVideoViewModel()
}

extension SLVideoViewModel {
    
    // MARK: - History
    func addVideoToHistory(videoId: Int, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        VideoRouter(endpoint: VideoEndpoint.HistoryAdded(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId)).request { (result) in
            switch result {
            case .Success(_):
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    func removeVideoHistory(videoId: Int, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        VideoRouter(endpoint: VideoEndpoint.HistoryRemoved(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId)).request { (result) in
            switch result {
            case .Success(_):
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Favourite
    func addVideoToFavourite(videoId: Int, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        VideoRouter(endpoint: VideoEndpoint.FavouriteAdded(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId)).request { (result) in
            switch result {
            case .Success(_):
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    func removeVideoFavourite(videoId: Int, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        VideoRouter(endpoint: VideoEndpoint.FavouriteRemoved(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: videoId)).request { (result) in
            switch result {
            case .Success(_):
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Rating
    func ratingVideo(userId: Int, videoId: Int, rating: Int, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        VideoRouter(endpoint: VideoEndpoint.RatingVideo(userId: userId, videoId: videoId, rating: rating)).request { (result) in
            switch result {
            case .Ok:
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
}
