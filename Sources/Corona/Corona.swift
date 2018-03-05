//
//  Corona.swift
//  Corona
//
//  Created by Vrisch on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

import Foundation

public enum Event {
    public enum Result {
        case empty
        case string(String)
        case attributedString(NSAttributedString)
        case index(Int)
        case indexPath(IndexPath)
        case range(NSRange)
    }
    
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
