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

public struct Event {
    
    public enum Kind {
        case editingChanged
        case editingDidEndOnExit
        case primaryActionTriggered
        case textViewDidChange
        case textViewDidChangeSelection
        case textViewDidEndEditing
        case touchUpInside
        case valueChanged
    }
    
    public init(configure: @escaping (Kind, @escaping (Result) throws -> Void) -> [Any]) {
        self.configure = configure
    }

    public func editingChanged(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.editingChanged, action)
    }

    public func editingDidEndOnExit(action: @escaping () throws -> Void) -> [Any] {
        return configure(.editingDidEndOnExit, { _ in
            try action()
        })
    }

    public func primaryActionTriggered(action: @escaping () throws -> Void) -> [Any] {
        return configure(.primaryActionTriggered, { _ in
            try action()
        })
    }

    public func textViewDidChange(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.textViewDidChange, action)
    }

    public func textViewDidChangeSelection(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.textViewDidChangeSelection, action)
    }

    public func textViewDidEndEditing(action: @escaping () throws -> Void) -> [Any] {
        return configure(.textViewDidEndEditing, { _ in
            try action()
        })
    }

    public func touchUpInside(action: @escaping () throws -> Void) -> [Any] {
        return configure(.touchUpInside, { _ in
            try action()
        })
    }

    public func valueChanged(action: @escaping (Result) throws -> Void) -> [Any] {
        return configure(.valueChanged, action)
    }
    
    private let configure: (Kind, @escaping (Result) throws -> Void) -> [Any]
}
