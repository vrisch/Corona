//
//  Corona.swift
//  Corona
//
//  Created by Vrisch on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

import UIKit

public struct Bindings {
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
        public func string(result: (String) -> Void) -> Event {
            switch self {
            case let .actionPerformed(.string(value)): result(value)
            case let .selectionChanged(.string(value)): result(value)
            case let .valueChanged(.string(value)): result(value)
            default: break
            }
            return self
        }
        @discardableResult
        public func attributedString(result: (NSAttributedString) -> Void) -> Event {
            switch self {
            case let .actionPerformed(.attributedString(value)): result(value)
            case let .selectionChanged(.attributedString(value)): result(value)
            case let .valueChanged(.attributedString(value)): result(value)
            default: break
            }
            return self
        }
        @discardableResult
        public func range(result: (NSRange) -> Void) -> Event {
            switch self {
            case let .actionPerformed(.range(value)): result(value)
            case let .selectionChanged(.range(value)): result(value)
            case let .valueChanged(.range(value)): result(value)
            default: break
            }
            return self
        }
    }
    public typealias Change = (Event) -> Void

    public init() {}

    public mutating func bind(_ barButtonItem: UIBarButtonItem?, change: @escaping Change) {
        tokens.append(TargetSelector(target: barButtonItem, change: change))
    }
    
    public mutating func bind(_ control: UIControl?, change: @escaping Change) {
        tokens.append(TargetSelector(target: control, change: change))
    }
    
    public mutating func bind(_ textView: UITextView?, change: @escaping Change) {
        tokens.append(TextViewDelegate(target: textView, change: change))
    }
    
    private var tokens : [Any] = []
}
