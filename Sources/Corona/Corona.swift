//
//  Corona.swift
//  Corona
//
//  Created by Vrisch on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

import Foundation

public enum Result {
    case empty
    case string(String)
    case attributedString(NSAttributedString)
    case index(Int)
    case indexPath(IndexPath)
    case range(NSRange)
}

public struct Event2 {
    
    public enum Kind {
        case editingChanged
        case editingDidEndOnExit
        case primaryActionTriggered
        case valueChanged
    }
    
    public init(configure: @escaping (Kind, @escaping (Result) throws -> Void) -> [Any]) {
        self.configure = configure
    }

    public func editingChanged(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.editingChanged, action)
    }

    public func editingDidEndOnExit(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.editingDidEndOnExit, action)
    }

    public func primaryActionTriggered(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.primaryActionTriggered, action)
    }

    public func valueChanged(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.valueChanged, action)
    }
    
    private let configure: (Kind, @escaping (Result) throws -> Void) -> [Any]
}

public struct Binder2 {
    
    public static func bind(_ binder: Binder2) throws -> Event2 {
        return binder.binding()!
    }
    
    public init(binding: @escaping () -> Event2?) {
        self.binding = binding
    }
    
    private let binding: () -> Event2?
}

public class TargetAction2: NSObject {
    public init(target: NSObject, perform: @escaping () throws -> Void, add: (TargetAction2) -> Void, remove: @escaping (TargetAction2) -> Void) {
        self.target = target
        self.perform = perform
        self.remove = remove
        super.init()
        add(self)
    }
    
    deinit {
        remove(self)
    }
    
    @objc public func action(_ sender: Any) {
        try! perform()
    }
    
    private weak var target: NSObject?
    private let perform: () throws -> Void
    private let remove: (TargetAction2) -> Void
}

public enum Event {
    case actionPerformed(Result)
    case selectionChanged(Result)
    case valueChanged(Result)
    
    @discardableResult
    public func empty(result: () throws -> Void) throws -> Event {
        switch self {
        case .actionPerformed(.empty): try result()
        case .selectionChanged(.empty): try result()
        case .valueChanged(.empty): try result()
        default: break
        }
        return self
    }

    @discardableResult
    public func string(result: (String) throws -> Void) throws -> Event {
        switch self {
        case let .actionPerformed(.string(value)): try result(value)
        case let .selectionChanged(.string(value)): try result(value)
        case let .valueChanged(.string(value)): try result(value)
        default: break
        }
        return self
    }

    @discardableResult
    public func attributedString(result: (NSAttributedString) throws -> Void) throws -> Event {
        switch self {
        case let .actionPerformed(.attributedString(value)): try result(value)
        case let .selectionChanged(.attributedString(value)): try result(value)
        case let .valueChanged(.attributedString(value)): try result(value)
        default: break
        }
        return self
    }

    @discardableResult
    public func range(result: (NSRange) throws -> Void) throws -> Event {
        switch self {
        case let .actionPerformed(.range(value)): try result(value)
        case let .selectionChanged(.range(value)): try result(value)
        case let .valueChanged(.range(value)): try result(value)
        default: break
        }
        return self
    }
}

public typealias Change = (Event) throws -> Void

public struct Binder {

    public init(binding: @escaping (@escaping Change) -> [Any]) {
        self.binding = binding
    }

    public static func bind(_ binder: Binder, change: @escaping Change) -> [Any] {
        return binder.binding(change)
    }

    private let binding: (@escaping Change) -> [Any]
}

public class TargetAction: NSObject {
    public init(target: NSObject, change: @escaping Change, add: (TargetAction) -> Void, transform: @escaping (Change) throws -> Void, remove: @escaping (TargetAction) -> Void) {
        self.target = target
        self.change = change
        self.transform = transform
        self.remove = remove
        super.init()
        add(self)
    }
    
    deinit {
        remove(self)
    }

    @objc public func action(_ sender: Any) {
        try! transform(change)
    }

    private weak var target: NSObject?
    private let change: Change
    private let transform: (Change) throws -> Void
    private let remove: (TargetAction) -> Void
}
