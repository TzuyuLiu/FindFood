//
//  XCTTestCase+MemoryLeakTracking.swift
//  FindFoodTests
//
//  Created by 劉子瑜-20001220 on 2024/6/26.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        // run after each test
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak ", file: file, line: line)
        }
    }
}
