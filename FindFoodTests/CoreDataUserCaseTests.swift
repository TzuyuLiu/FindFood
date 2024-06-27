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

    func login(_ result: Result<User, Error>, completion: @escaping (Error?) -> Void) {
        switch result {
        case .success(let user):
            store.save(user) { error in
                completion(error)
            }
        case .failure(let failure):
            completion(failure)
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

    func completeSave(with error: Error) {
        saveCompletion?(error)
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

        sut.login(.success(makeUser())) { _ in }

        XCTAssertNotNil(store.user)
    }

    func test_save_requestLoginSuccessButSaveFail() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?

        sut.login(.success(makeUser())) { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeSave(with: makeAnyError())

        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }

    func test_save_requestLoginFail() {
        let (sut, _) = makeSUT()
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        let loginError = makeAnyError()

        sut.login(.failure(loginError)) { error in
            receivedError = error
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, loginError)
    }

    func test_delete_requestLogoutUponDoesnotHaveAUser() {
        let (sut, _) = makeSUT()

        XCTAssertThrowsError(try sut.logout())
    }

    func test_delete_requestLogoutUponUserStoreHasAUser() {
        let (sut, store) = makeSUT()
        sut.login(.success(makeUser())) { _ in }

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

    private func makeAnyError() -> NSError {
        return NSError(domain: "An Error", code: 0)
    }
}
