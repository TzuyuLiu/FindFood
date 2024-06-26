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

    func login(_ result: Result<User, Error>) {
        switch result {
        case .success(let user):
            store.save(user)
        case .failure(let failure):
            ()
        }
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

        sut.login(.success(makeUser()))

        XCTAssertNotNil(store.user)
    }

    func test_save_requestLoginFail() {
        let (sut,store) = makeSUT()

        sut.login(.failure(makeError()))

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

    private func makeError() -> Error {
        return NSError(domain: "An Error", code: 999)
    }
}
