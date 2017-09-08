//
//  AppkitExtensions.swift
//  Corona-macOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

import Orbit
import Cocoa

public func bind(_ toolbarItem: NSToolbarItem?, change: @escaping Change) -> Disposables {
    return Disposables(object: TargetSelector(target: toolbarItem, change: change))
}

public func bind(_ control: NSControl?, change: @escaping Change) -> Disposables {
    return Disposables(object: TargetSelector(target: control, change: change))
}

internal class TargetSelector: NSObject {
    init(target: NSControl?, change: @escaping Change) {
        self.toolbarItem = nil
        self.control = target
        self.change = change
        super.init()
        
        control?.target = self
        control?.action = #selector(touchUpInside(_:))
    }

    init(target: NSToolbarItem?, change: @escaping Change) {
        self.toolbarItem = target
        self.control = nil
        self.change = change
        super.init()
        
        toolbarItem?.target = self
        toolbarItem?.action = #selector(touchUpInside(_:))
    }

    deinit {
        toolbarItem?.target = nil
        toolbarItem?.action = nil
        control?.target = nil
        control?.action = nil
    }

    @objc func touchUpInside(_ sender: Any) {
        try! change(.actionPerformed(.empty))
    }

    private weak var toolbarItem: NSToolbarItem?
    private weak var control: NSControl?
    private let change: Change
}
