//
//  CoreDataUserCaseTests.swift
//  CoreDataUserCaseTests
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import XCTest
@testable import FindFood

class LocalUserLoader {
    private let store: UserStore

    init(store: UserStore) {
        self.store = store
    }

    func loginSuccess(_ user: User) {
        store.save(user)
    }

    func loginFail() {

    }
}

class UserStore {
    var user: User?

    func save(_ user: User) {
        self.user = user
    }
}

final class CoreDataUserCaseTests: XCTestCase {
    func test_init_doseNotHaveAUserUponCreation() {
        let (_,store) = makeSUT()

        XCTAssertNil(store.user)
    }

    func test_save_requestLoginSuccess() {
        let (sut,store) = makeSUT()

        sut.loginSuccess(makeUser())

        XCTAssertNotNil(store.user)
    }

    func test_save_requestLoginFail() {
        let (sut,store) = makeSUT()

        sut.loginFail()

        XCTAssertNil(store.user)
    }

    // MARK: Helper
    private func makeSUT() -> (LocalUserLoader, UserStore) {
        let store = UserStore()
        let sut = LocalUserLoader(store: store)

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)

        return (sut, store)
    }

    private func makeUser() -> User {
        return User(name: "Andy",
                    image: nil,
                    idToken: "12345",
                    loginType: .facebook)
    }
}
