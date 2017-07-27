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
        
        func string(result: (String) -> Void) {
            switch self {
            case let .actionPerformed(.string(value)): result(value)
            case let .selectionChanged(.string(value)): result(value)
            case let .valueChanged(.string(value)): result(value)
            default: break
            }
        }
    }
    typealias Change = (Event) -> Void

    mutating func bind(_ barButtonItem: UIBarButtonItem?, change: @escaping Change) {
        tokens.append(TargetSelector(target: barButtonItem, change: change))
    }
    
    mutating func bind(_ control: UIControl?, change: @escaping Change) {
        tokens.append(TargetSelector(target: control, change: change))
    }
    
    mutating func bind(_ textView: UITextView?, change: @escaping Change) {
        tokens.append(TextViewDelegate(target: textView, change: change))
    }
    
    private var tokens : [Any] = []
}
