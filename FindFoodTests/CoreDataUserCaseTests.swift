//
//  CoreDataUserCaseTests.swift
//  CoreDataUserCaseTests
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import XCTest
@testable import FindFood

class LocalUserLoader {
    init(store: UserStore) {

    }
}

class UserStore {
    var user: User?
}

final class CoreDataUserCaseTests: XCTestCase {
    func test_init_doseNotHaveAUserUponCreation() {
        let store = UserStore()
        _ = LocalUserLoader(store: store)

        XCTAssertNil(store.user)
    }
}
