//
//  Corona.swift
//  Corona
//
//  Created by Vrisch on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

import Orbit
import UIKit

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

public func bind(_ barButtonItem: UIBarButtonItem?, change: @escaping Change) -> Disposables {
    return Disposables(object: TargetSelector(target: barButtonItem, change: change))
}

public func bind(_ control: UIControl?, change: @escaping Change) -> Disposables {
    return Disposables(object: TargetSelector(target: control, change: change))
}

public func bind(_ textView: UITextView?, change: @escaping Change) -> Disposables {
    return Disposables(object: TextViewDelegate(target: textView, change: change))
}

