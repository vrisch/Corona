//
//  CoronaTests.swift
//  Corona
//
//  Created by Vrisch on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

import Foundation
import XCTest
import Corona

class CoronaTests: XCTestCase {
    func testExample() {
        #if os(OSX)
        let test = NSToolbarItem()
        var disposables: [Any] = []
        disposables += Binder.bind(.toolbarItem(test)) { _ in
        }
        #endif
    }
    
    static var allTests = [
        ("testExample", testExample),
        ]
}
