//
//  AppkitExtensions.swift
//  Corona-macOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

import Orbit
import Cocoa

public extension Binder {

    public static let toolbarItem: (NSToolbarItem) -> Binder = { toolbarItem in
        return Binder { change in
            let targetAction = TargetAction(
                target: toolbarItem,
                change: change,
                add: { targetAction in
                    toolbarItem.target = targetAction
                    toolbarItem.action = #selector(TargetAction.action(_:))
            },
                transform: { change in
                    try change(.actionPerformed(.empty))
            },
                remove: { targetAction in
                    toolbarItem.target = nil
                    toolbarItem.action = nil
            })
            return Disposables(object: targetAction)
        }
    }
}
