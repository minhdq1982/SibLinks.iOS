//
//  StateViewControllerImplementation.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/21/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit


// MARK: Default Implementation BackingViewProvider

extension BackingViewProvider where Self: UIViewController {
    var backingView: UIView {
        return view
    }
}

extension BackingViewProvider where Self: UIView {
    var backingView: UIView {
        return self
    }
}


// MARK: Default Implementation StateViewController

/// Default implementation of StateViewController for UIViewController
extension StateViewController {
    
    var stateMachine: ViewStateMachine {
        return associatedObject(self, key: &stateMachineKey) { [unowned self] in
            return ViewStateMachine(view: self.backingView)
        }
    }
    
    var currentState: StateViewControllerState {
        switch stateMachine.currentState {
        case .None: return .Content
        case .View(let viewKey): return StateViewControllerState(rawValue: viewKey)!
        }
    }
    
    var lastState: StateViewControllerState {
        switch stateMachine.lastState {
        case .None: return .Content
        case .View(let viewKey): return StateViewControllerState(rawValue: viewKey)!
        }
    }
    
    
    // MARK: Views
    
    var loadingView: UIView? {
        get { return placeholderView(.Loading) }
        set { setPlaceholderView(newValue, forState: .Loading) }
    }
    
    var errorView: UIView? {
        get { return placeholderView(.Error) }
        set { setPlaceholderView(newValue, forState: .Error) }
    }
    
    var emptyView: UIView? {
        get { return placeholderView(.Empty) }
        set { setPlaceholderView(newValue, forState: .Empty) }
    }
    
    
    // MARK: Transitions
    
    func setupInitialViewState(completion: (() -> Void)? = nil) {
        let isLoading = (lastState == .Loading)
        let error: NSError? = (lastState == .Error) ? NSError(domain: "com.siblinks.StateViewController.ErrorDomain", code: -1, userInfo: nil) : nil
        transitionViewStates(isLoading, error: error, animated: false, completion: completion)
    }
    
    func startLoading(animated: Bool = false, completion: (() -> Void)? = nil) {
        transitionViewStates(true, animated: animated, completion: completion)
    }
    
    func endLoading(animated: Bool = true, error: ErrorType? = nil, completion: (() -> Void)? = nil) {
        transitionViewStates(false, animated: animated, error: error, completion: completion)
    }
    
    func transitionViewStates(loading: Bool = false, error: ErrorType? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        // Update view for content (i.e. hide all placeholder views)
        if hasContent() {
            if let e = error {
                // show unobstrusive error
                handleErrorWhenContentAvailable(e)
            }
            self.stateMachine.transitionToState(.None, animated: animated, completion: completion)
            return
        }
        
        // Update view for placeholder
        var newState: StateViewControllerState = .Empty
        if loading {
            newState = .Loading
        } else if let _ = error {
            newState = .Error
        }
        self.stateMachine.transitionToState(.View(newState.rawValue), animated: animated, completion: completion)
    }
    
    // MARK: Content and error handling
    
    func hasContent() -> Bool {
        return true
    }
    
    func handleErrorWhenContentAvailable(error: ErrorType) {
        // Default implementation does nothing.
    }
    
    // MARK: Helper
    
    private func placeholderView(state: StateViewControllerState) -> UIView? {
        return stateMachine[state.rawValue]
    }
    
    private func setPlaceholderView(view: UIView?, forState state: StateViewControllerState) {
        stateMachine[state.rawValue] = view
    }
}

// MARK: Association

private var stateMachineKey: UInt8 = 0

private func associatedObject<T: AnyObject>(host: AnyObject, key: UnsafePointer<Void>, initial: () -> T) -> T {
    var value = objc_getAssociatedObject(host, key) as? T
    if value == nil {
        value = initial()
        objc_setAssociatedObject(host, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    return value!
}
