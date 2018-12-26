//
//  SLAdmissionMenuControllerOptions.swift
//  SibLinks
//
//  Created by ANHTH on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import PagingMenuController

private var pagingControllers: [UIViewController] {
    let myEssayViewController = SLMyEssayViewController.controller
    let beforeApplyViewController = SLBeforeApplyViewController.controller
    let sampleEssayViewController = SLSampleApplyViewController.controller
    
    return [myEssayViewController, beforeApplyViewController, sampleEssayViewController]
}

struct MenuItemMyEssay: MenuItemViewCustomizable {}
struct MenuItemBeforeApply: MenuItemViewCustomizable {}
struct MenuItemSampleEssay: MenuItemViewCustomizable {}

struct AdmissionMenuOptions: PagingMenuControllerCustomizable {
    
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
            return .Standard(widthMode: .Flexible, centerItem: false, scrollingMode: .ScrollEnabledAndBouces)
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
            let title = MenuItemText(text: "My Essays".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(11.dynamicFont3()),
                                     selectedFont: Constants.boldFontOfSize(11.dynamicFont3()))
            return .Text(title: title)
        }
    }
    
    struct MenuItemRate: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Before Apply".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(11.dynamicFont3()),
                                     selectedFont: Constants.boldFontOfSize(11.dynamicFont3()))
            return .Text(title: title)
        }
    }
    
    struct MenuItemLike: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Sample Applications".localized,
                                     color: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     selectedColor: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                     font: Constants.regularFontOfSize(11.dynamicFont3()),
                                     selectedFont: Constants.boldFontOfSize(11.dynamicFont3()))
            return .Text(title: title)
        }
    }
    
}
