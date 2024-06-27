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
            store.save(user) { error in

            }
        case .failure(let failure):
            ()
        }
    }

    func logout() throws {
        guard store.user != nil else {
            throw NSError(domain: "Doesn't have a user.", code: 998)
        }

        store.deleteUser()
    }
}

class UserStore {
    private(set) var user: User?
    private var saveCompletion: SaveCompletions?

    typealias SaveCompletions = (Error?) -> Void

    func save(_ user: User, completion: @escaping SaveCompletions) {
        self.user = user
        saveCompletion = completion
    }

    func deleteUser() {
        self.user = nil
    }

    func completeSaveSuccessfully() {
        saveCompletion = nil
    }
}

final class CoreDataUserCaseTests: XCTestCase {
    func test_init_doseNotHaveAUserUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertNil(store.user)
    }

    func test_save_requestLoginSuccess() {
        let (sut, store) = makeSUT()

        sut.login(.success(makeUser()))

        XCTAssertNotNil(store.user)
    }

    func test_save_requestLoginFail() {
        let (sut, store) = makeSUT()

        sut.login(.failure(makeError()))

        XCTAssertNil(store.user)
    }

    func test_delete_requestLogoutUponDoesnotHaveAUser() {
        let (sut, _) = makeSUT()

        XCTAssertThrowsError(try sut.logout())
    }

    func test_delete_requestLogoutUponUserStoreHasAUser() {
        let (sut, store) = makeSUT()
        sut.login(.success(makeUser()))

        try? sut.logout()

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
