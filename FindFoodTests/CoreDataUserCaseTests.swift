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
            store.save(user) { [weak self] error in
                guard let self = self else { return }
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

    func load() {
        store.retrieve()
    }
}

protocol UserStore {
    var user: User? { get }
    typealias SaveCompletions = (Error?) -> Void

    func save(_ user: User, completion: @escaping SaveCompletions)
    func deleteUser()
    func retrieve()
}

class UserStoreSpy: UserStore {
    enum ReceivedMessage: Equatable {
        case save
        case delete
        case retrieve
    }

    private(set) var user: User?
    private var saveCompletion: SaveCompletions?
    private(set) var receivedMessages = [ReceivedMessage]()

    typealias SaveCompletions = (Error?) -> Void

    func save(_ user: User, completion: @escaping SaveCompletions) {
        self.user = user
        saveCompletion = completion
        receivedMessages.append(.save)
    }

    func deleteUser() {
        self.user = nil
        receivedMessages.append(.delete)
    }

    func retrieve() {
        receivedMessages.append(.retrieve)
    }

    func completeSave(with error: Error) {
        saveCompletion?(error)
    }

    func completeSaveSuccessfully() {
        saveCompletion?(nil)
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
        let saveError = makeAnyError()
        expect(sut, loginResult: .success(makeUser()), toCompleteWithError: saveError) {
            store.completeSave(with: saveError)
        }
    }

    func test_save_requestLoginSuccessAndSaveSuccess() {
        let (sut, store) = makeSUT()
        expect(sut, loginResult: .success(makeUser()), toCompleteWithError: nil) {
            store.completeSaveSuccessfully()
        }
    }

    func test_save_requestLoginFail() {
        let (sut, _) = makeSUT()
        let loginError = makeAnyError()
        expect(sut, loginResult: .failure(loginError), toCompleteWithError: loginError) { }
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

    func test_save_doesNotDeliveryDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = UserStoreSpy()
        var sut: LocalUserLoader? = LocalUserLoader(store: store)

        var receivedError: Error?

        sut?.login(.success(makeUser()), completion: { error in
            receivedError = error
        })

        sut = nil

        store.completeSave(with: makeAnyError())

        XCTAssertNil(receivedError)
    }

    func test_load_requestsCoreDataRetriveal() {
        let (sut, store) = makeSUT()

        sut.load()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    // MARK: Helper

    private func expect(_ sut: LocalUserLoader, loginResult expectedLoginResult: Result<User, any Error>, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?

        sut.login(expectedLoginResult) { error in
            receivedError = error
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }

    private func makeSUT() -> (LocalUserLoader, UserStoreSpy) {
        let store = UserStoreSpy()
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
