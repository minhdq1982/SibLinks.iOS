//
//  PagesController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

protocol PagesControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, setViewController viewController: UIViewController, atPage page: Int)
}

class PagesController: UIPageViewController {
    
    var startPage = 0
    var setNavigationTitle = true
    
    var enableSwipe = true {
        didSet {
            toggle()
        }
    }
    
    lazy var pages = Array<UIViewController>()
    
    var pagesCount: Int {
        return pages.count
    }
    
    private(set) var currentIndex = 0
    
    var pagesDelegate: PagesControllerDelegate?
    
    convenience init(_ pages: [UIViewController],
                              transitionStyle: UIPageViewControllerTransitionStyle = .Scroll,
                              navigationOrientation: UIPageViewControllerNavigationOrientation = .Horizontal,
                              options: [String : AnyObject]? = nil) {
        self.init(transitionStyle: transitionStyle,
                  navigationOrientation: navigationOrientation,
                  options: options)
        
        setup(pages)
    }
    
    func setup(pages: [UIViewController]) {
        add(pages)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        goTo(startPage)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: Public methods
extension PagesController {
    
    func goTo(index: Int) {
        if index >= 0 && index < pages.count {
            let direction: UIPageViewControllerNavigationDirection = (index > currentIndex) ? .Forward : .Reverse
            let viewController = pages[index]
            currentIndex = index
            setViewControllers([viewController],
                               direction: direction,
                               animated: true,
                               completion: { [unowned self] finished in
                                self.pagesDelegate?.pageViewController(self,
                                    setViewController: viewController,
                                    atPage: self.currentIndex)
                })
            if setNavigationTitle {
                title = viewController.title
            }
        }
    }
    
    func next() {
        goTo(currentIndex + 1)
    }
    
    func previous() {
        goTo(currentIndex - 1)
    }
    
    func add(viewControllers: [UIViewController]) {
        for viewController in viewControllers {
            addViewController(viewController)
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension PagesController : UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = prevIndex(viewControllerIndex(viewController))
        return pages.at(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index: Int? = nextIndex(viewControllerIndex(viewController))
        return pages.at(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

// MARK: UIPageViewControllerDelegate

extension PagesController : UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let viewController = pageViewController.viewControllers?.last,
                index = viewControllerIndex(viewController) {
                currentIndex = index
                
                if setNavigationTitle {
                    title = viewController.title
                }
                
                pagesDelegate?.pageViewController(self, setViewController: pages[currentIndex], atPage: currentIndex)
            }
        }
    }
}

// MARK: Private methods

extension PagesController {
    
    func viewControllerIndex(viewController: UIViewController) -> Int? {
        return pages.indexOf(viewController)
    }
    
    private func toggle() {
        for subview in view.subviews {
            if let subview = subview as? UIScrollView {
                subview.scrollEnabled = enableSwipe
                break
            }
        }
    }
    
    private func addViewController(viewController: UIViewController) {
        pages.append(viewController)
        
        if pages.count == 1 {
            setViewControllers([viewController],
                               direction: .Forward,
                               animated: true,
                               completion: { [unowned self] finished in
                                self.pagesDelegate?.pageViewController(self,
                                    setViewController: viewController,
                                    atPage: self.currentIndex)
                })
            if setNavigationTitle {
                title = viewController.title
            }
        }
    }
}

// MARK: Storyboard

extension PagesController {
    
    convenience init(_ storyboardIds: [String], storyboard: UIStoryboard) {
        let pages = storyboardIds.map(storyboard.instantiateViewControllerWithIdentifier)
        self.init(pages)
    }
}