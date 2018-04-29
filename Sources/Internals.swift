//
//  Internals.swift
//  Corona
//
//  Created by Magnus on 2018-04-29.
//  Copyright © 2018 Corona. All rights reserved.
//

import Foundation

internal class TargetAction: NSObject {
    internal init(target: NSObject, perform: @escaping () throws -> Void, add: (TargetAction) -> Void, remove: @escaping (TargetAction) -> Void) {
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
    private let remove: (TargetAction) -> Void
}
