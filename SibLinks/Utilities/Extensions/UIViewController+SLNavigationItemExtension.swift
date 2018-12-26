//
//  UIViewController+SLNavigationItemExtension.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

/** SLNavigationItemExtension Extends UIViewController

 */

enum ItemPosition {
    case Left, Right
}

enum ItemType {
    case Back, Space, Menu, Search, Upload, Ask, Filter, Loading, Resend, Edit, Delete
}

private let overlayTag = 1001

extension UIViewController {
    
    func navigationBarButtonItems(items: [(ItemType, ItemPosition)]?) {
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItems = nil

        let backButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(goback(_:)))
        self.navigationItem.backBarButtonItem = backButtonItem

        guard let items = items else {
            return
        }

        var rightBarButtonItems = [UIBarButtonItem]()
        var leftBarButtonItems = [UIBarButtonItem]()

        for (key, value) in items {
            var item: UIBarButtonItem?
            switch key {
            case .Back:
                let backButton = UIButton(frame: CGRectMake(0, 0, 60, 44))
                backButton.setImage(UIImage(named: "Back"), forState: .Normal)
                backButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
                backButton.setTitle("Back".localized, forState: .Normal)
                backButton.setTitleColor(UIColor(hexString: Constants.SIBLINKS_NAV_COLOR), forState: .Normal)
                backButton.titleLabel?.font = Constants.regularFontOfSize(14)
                backButton.addTarget(self, action: #selector(goback(_:)), forControlEvents: .TouchUpInside)
                backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
                let backItem = UIBarButtonItem(customView: backButton)
                item = backItem

                break
                
            case .Space:
                let spaceItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
                item = spaceItem
                
                break
            case .Search:
                let searchItem = UIBarButtonItem(image: UIImage(named: "Search"), style: .Plain, target: self, action: #selector(search))
                item = searchItem
                
                break
            case .Upload:
                let uploadItem = UIBarButtonItem(image: UIImage(named: "UploadIcon"), style: .Plain, target: self, action: #selector(uploadAction))
                item = uploadItem
                
                break
			case .Menu:
                let menuItem = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: self, action: #selector(presentLeftMenuViewController(_:)))
                item = menuItem

                break
            case .Ask:
                let askItem = UIBarButtonItem(image: UIImage(named: "icon-ask"), style: .Plain, target: self, action: #selector(ask))
                item = askItem
                
                break
            case .Filter:
                let filterItem = UIBarButtonItem(image: UIImage(named: "Filter"), style: .Plain, target: self, action: #selector(filter))
                item = filterItem
                
                break
            case .Loading:
                let loadingView = AnimatableActivityIndicatorView(frame: CGRectMake(0, 0, 28, 28))
                loadingView.animationType = "BallClipRotate"
                loadingView.color = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
                loadingView.startAnimating()
                let loadingItem = UIBarButtonItem(customView: loadingView)
                item = loadingItem
                
                break
            case .Resend:
                let resendItem = UIBarButtonItem(title: "Resend".localized, style: .Plain, target: self, action: #selector(resend))
                item = resendItem
                
                break
            case .Edit:
                let editItem = UIBarButtonItem(title: "Edit".localized, style: .Plain, target: self, action: #selector(edit))
                item = editItem
                
                break
            case .Delete:
                let deleteItem = UIBarButtonItem(image: UIImage(named: "DeleteIcon"), style: .Plain, target: self, action: #selector(remove))
                item = deleteItem
                
                break
            }

            guard let guardItem = item else {
                continue
            }

            switch value {
            case .Right:
                rightBarButtonItems.append(guardItem)

                break
            case .Left:
                leftBarButtonItems.append(guardItem)

                break
            }
        }

        self.navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
        self.navigationItem.setLeftBarButtonItems(leftBarButtonItems, animated: false)
    }
}

extension UIViewController {

    // MARK: - Actions
    func goback(sender: UIBarButtonItem) {
        if self.navigationController?.viewControllers.count > 1 {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

	func ask(sender: UIBarButtonItem) {
        
    }
    
    func filter(sender: UIBarButtonItem) {
        
    }
    
    func search(sender: UIBarButtonItem) {
        
        // Add search bar
        
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.searchBarStyle = .Minimal
        
        // Add overlay view
        
        let overlayView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.tag = overlayTag
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        overlayView.addGestureRecognizer(tap)
        
        UIView.animateWithDuration(0.3, animations: {
            
            }) { (finished) in
                self.navigationItem.rightBarButtonItems = nil
                self.navigationItem.titleView = searchBar
                searchBar.alpha = 0
                overlayView.alpha = 0;
                self.view.addSubview(overlayView)
                
                UIView.animateWithDuration(0.3, animations: {
                    searchBar.alpha = 1
                    overlayView.alpha = 0.6
                    }, completion: { (finished) in
                        searchBar.becomeFirstResponder()
                })
        }
    }
    
    func openSlideMenu(sender: UIBarButtonItem) {
        
    }
    
    func uploadAction(sender: UIBarButtonItem) {
        
    }
    
    func searchObject(clear: Bool) {
        
    }
    
    func resend(sender: UIBarButtonItem) {
        
    }
    
    func edit(sender: UIBarButtonItem) {
        
    }
    
    func remove(sender: UIBarButtonItem) {
        
    }
    
    func dismissKeyboard() {
        if let searchBar = self.navigationItem.titleView as? UISearchBar {
            searchBar.resignFirstResponder()
            self.searchBarCancelButtonClicked(searchBar)
        }
    }
    
    func searchDidEndEditing() {
        
    }
    
}

extension UIViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBarDelegate
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchDidEndEditing()
        enableCancleButton(searchBar)
        UIView.animateWithDuration(0.3, animations: {
            if let searchBar = self.navigationItem.titleView as? UISearchBar {
                searchBar.alpha = 0
            }
            }) { (finished) in
                self.navigationItem.titleView = nil
                self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right), (ItemType.Search, ItemPosition.Right)])
                self.searchObject(true)
        }
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchObject(false)
    }
    
    func enableCancleButton (searchBar : UISearchBar) {
        for view1 in searchBar.subviews {
            for view2 in view1.subviews {
                if let button = view2 as? UIButton {
                    button.enabled = true
                    button.userInteractionEnabled = true
                }
            }
        }
        
        if let overlayView = view.viewWithTag(overlayTag) {
            overlayView.removeFromSuperview()
        }
    }
    
}
