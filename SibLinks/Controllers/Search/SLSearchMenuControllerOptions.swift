//
//  SLSearchMenuControllerOptions.swift
//  SibLinks
//
//  Created by ANHTH on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import PagingMenuController

private var pagingControllers: [UIViewController] {
    let videoViewController = SLSearchVideoViewController.controller
    let playlistViewController = SLSearchPlaylistViewController.controller
    
    return [videoViewController, playlistViewController]
}

struct MenuItemSearchVideo: MenuItemViewCustomizable {}
struct MenuItemSearchPlaylist: MenuItemViewCustomizable {}

struct SearchMenuOptions: PagingMenuControllerCustomizable {
    
    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    
    struct MenuOptions: MenuViewCustomizable {

        var backgroundColor: UIColor {
            return UIColor(hexString: Constants.SIBLINKS_PAGE_BACKGROUND_COLOR)
        }
        
        var selectedBackgroundColor: UIColor {
            return UIColor.clearColor()
        }
        
        var displayMode: MenuDisplayMode {
            return .SegmentedControl
        }
        
        var focusMode: MenuFocusMode {
            return .Underline(height: 3, color: UIColor(hexString: Constants.SIBLINKS_UNDERLINE_SELECTED), horizontalPadding: 15.0, verticalPadding: 0.0)
        }
        
        var height: CGFloat {
            return 51.5
        }
        
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemSearchVideo(), MenuItemSearchPlaylist()]
        }
        
    }
    
    struct MenuItemSearchVideo: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "VIDEOS".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
    
    struct MenuItemSearchPlaylist: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "PLAYLISTS".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(12.dynamicFont2()),
                                     selectedFont: Constants.boldFontOfSize(12.dynamicFont2()))
            return .Text(title: title)
        }
    }
}
