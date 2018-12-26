//
//  SLMentorMenuControllerOptions.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import PagingMenuController

private var pagingControllers: [UIViewController] {
    let subscriberViewController = SLTopSubscriberViewController.instantiateFromStoryboard(Constants.MENTOR_STORYBOARD)
    let rateViewController = SLTopRatesViewController.instantiateFromStoryboard(Constants.MENTOR_STORYBOARD)
    let likeViewController = SLTopLikesViewController.instantiateFromStoryboard(Constants.MENTOR_STORYBOARD)
    
    return [subscriberViewController, rateViewController, likeViewController]
}

struct MenuItemSubscriber: MenuItemViewCustomizable {}
struct MenuItemRate: MenuItemViewCustomizable {}
struct MenuItemLike: MenuItemViewCustomizable {}

struct MentorMenuOptions: PagingMenuControllerCustomizable {
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
            return [MenuItemSubscriber(), MenuItemRate(), MenuItemLike()]
        }
    }
    
    struct MenuItemSubscriber: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Most Subscribed".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(11.dynamicFont3()),
                                     selectedFont: Constants.boldFontOfSize(11.dynamicFont3()))
            return .Text(title: title)
        }
    }
    struct MenuItemRate: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Highest Rated".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(11.dynamicFont3()),
                                     selectedFont: Constants.boldFontOfSize(11.dynamicFont3()))
            return .Text(title: title)
        }
    }
    struct MenuItemLike: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Most Liked".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(11.dynamicFont3()),
                                     selectedFont: Constants.boldFontOfSize(11.dynamicFont3()))
            return .Text(title: title)
        }
    }
}
