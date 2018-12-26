//
//  VideoMenuControllerOptions.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import PagingMenuController

// MARK: - Subscriber Menu
private var pagingControllers: [UIViewController] {
    let homeViewController = SLVideoHomeViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
    let subscriptionsViewController = SLVideoSubscriptionsViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
    let accountViewController = SLVideoAccountViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
    
    return [homeViewController, subscriptionsViewController, accountViewController]
}

struct MenuItemHome: MenuItemViewCustomizable {}
struct MenuItemSubscriptions: MenuItemViewCustomizable {}
struct MenuItemAccount: MenuItemViewCustomizable {}

struct VideoMenuOptions: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor: UIColor {
            return UIColor(hexString: Constants.SIBLINKS_SIDE_MENU_BACK_COLOR)
        }
        var selectedBackgroundColor: UIColor {
            return UIColor(hexString: Constants.SIBLINKS_SIDE_MENU_BACK_COLOR)
        }
        var displayMode: MenuDisplayMode {
            return .SegmentedControl
        }
        
        var focusMode: MenuFocusMode {
            return .Underline(height: 3, color: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR), horizontalPadding: 15.0, verticalPadding: 0.0)
        }
        
        var height: CGFloat {
            return 51.5
        }
        
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemHome(), MenuItemSubscriptions(), MenuItemAccount()]
        }
    }
    
    struct MenuItemHome: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Home".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_PAGE_MENU_COLOR),
                                     selectedColor: UIColor.whiteColor(),
                                     font: Constants.regularFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
    struct MenuItemSubscriptions: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Subscriptions".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_PAGE_MENU_COLOR),
                                     selectedColor: UIColor.whiteColor(),
                                     font: Constants.regularFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
    struct MenuItemAccount: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Account".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_PAGE_MENU_COLOR),
                                     selectedColor: UIColor.whiteColor(),
                                     font: Constants.regularFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
}

// MARK: - Subscriber Menu
private var subscriberPagingControllers: [UIViewController] {
    let videoViewController = SLVideoSubscriberListViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
    videoViewController.isSubscriptions = true
    let playlistViewController = SLVideoSubscriberPlayListViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
    
    return [videoViewController, playlistViewController]
}

struct MenuItemSubscriberVideo: MenuItemViewCustomizable {}
struct MenuItemSubscriberPlaylist: MenuItemViewCustomizable {}

struct VideoSubscriberMenuOptions: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: subscriberPagingControllers)
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor: UIColor {
            return UIColor(hexString: Constants.SIBLINKS_TABBAR_BACKGROUND_COLOR)
        }
        var selectedBackgroundColor: UIColor {
            return UIColor(hexString: Constants.SIBLINKS_TABBAR_BACKGROUND_COLOR)
        }
        var displayMode: MenuDisplayMode {
            return .SegmentedControl
        }
        
        var focusMode: MenuFocusMode {
            return .Underline(height: 3, color: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR), horizontalPadding: 0.0, verticalPadding: 0.0)
        }
        
        var height: CGFloat {
            return 51.5
        }
        
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemSubscriberVideo(), MenuItemSubscriberPlaylist()]
        }
    }
    struct MenuItemSubscriberVideo: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "VIDEOS".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_SEGMENTED_TEXT_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR),
                                     font: Constants.boldFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
    struct MenuItemSubscriberPlaylist: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "PLAYLISTS".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_SEGMENTED_TEXT_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR),
                                     font: Constants.boldFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
}

// MARK: - Detail Menu
private var detailPagingControllers: [UIViewController] {
    let videoViewController = SLVideoRelatedViewController()
    let commentViewController = SLVideoCommentViewController(style: .Grouped)
    
    return [videoViewController, commentViewController]
}

struct MenuItemRelatedVideo: MenuItemViewCustomizable {}
struct MenuItemComment: MenuItemViewCustomizable {}

struct VideoDetailMenuOptions: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: detailPagingControllers)
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor: UIColor {
            return UIColor(hexString: Constants.SIBLINKS_TABBAR_BACKGROUND_COLOR)
        }
        var selectedBackgroundColor: UIColor {
            return UIColor(hexString: Constants.SIBLINKS_TABBAR_BACKGROUND_COLOR)
        }
        var displayMode: MenuDisplayMode {
            return .SegmentedControl
        }
        
        var focusMode: MenuFocusMode {
            return .Underline(height: 3, color: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR), horizontalPadding: 0.0, verticalPadding: 0.0)
        }
        
        var height: CGFloat {
            return 51.5
        }
        
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemRelatedVideo(), MenuItemComment()]
        }
    }
    struct MenuItemRelatedVideo: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "RELATED VIDEOS".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_SEGMENTED_TEXT_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR),
                                     font: Constants.boldFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
    struct MenuItemComment: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "COMMENTS".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_SEGMENTED_TEXT_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR),
                                     font: Constants.boldFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
}
