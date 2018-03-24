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
    #if os(OSX)
    func testNSToolbarItem() {
        let test = NSToolbarItem()
        var disposables: [Any] = []
        disposables += Binder.bind(.toolbarItem(test)) { _ in
        }
    }
    #endif
    
    #if os(iOS)
    func testUIButton() {
        var test = 0
        var disposables: [Any] = []
        let button = UIButton()
        disposables += try! Binder2.bind(.control(button)).primaryActionTriggered { _ in
            test = 1
        }
        disposables += try! Binder2.bind(.control(button)).valueChanged { _ in
            test = 2
        }
        button.sendActions(for: .touchUpInside)
        XCTAssertEqual(test, 1)
        disposables.removeAll()
    }
    #endif
}
