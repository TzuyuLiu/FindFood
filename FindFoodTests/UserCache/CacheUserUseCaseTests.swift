//
//  CacheUserUseCaseTests.swift
//  CacheUserUseCaseTests
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import XCTest
@testable import FindFood

final class CacheUserUseCaseTests: XCTestCase {
    func test_init_doseNotHaveAUserUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertNil(store.user)
    }

    func test_save_requestLoginSuccess() {
        let (sut, store) = makeSUT()

        sut.login(.success(userA())) { _ in }

        XCTAssertNotNil(store.user)
    }

    func test_save_requestLoginSuccessButSaveFail() {
        let (sut, store) = makeSUT()
        let saveError = anyError()
        expect(sut, loginResult: .success(userA()), toCompleteWithError: saveError) {
            store.completeSave(with: saveError)
        }
    }

    func test_save_requestLoginSuccessAndSaveSuccess() {
        let (sut, store) = makeSUT()
        expect(sut, loginResult: .success(userA()), toCompleteWithError: nil) {
            store.completeSaveSuccessfully()
        }
    }

    func test_save_requestLoginFail() {
        let (sut, _) = makeSUT()
        let loginError = anyError()
        expect(sut, loginResult: .failure(loginError), toCompleteWithError: loginError) { }
    }

    func test_delete_requestLogoutUponDoesnotHaveAUser() {
        let (sut, _) = makeSUT()

        XCTAssertThrowsError(try sut.logout { _ in })
    }

    func test_delete_requestLogoutSuccessButDeleteFail() {
        let (sut, store) = makeSUT()
        let logoutError = anyError()
        let exp = expectation(description: "Wait for logout completion")
        sut.login(.success(userA())) { _ in }

        var receivedError: Error?
        try? sut.logout { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDelete(with: logoutError)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as? NSError, logoutError)
    }

    func test_delete_requestLogoutSuccessAndDeleteSuccess() {
        let (sut, store) = makeSUT()
        let logoutError = anyError()
        let exp = expectation(description: "Wait for logout completion")
        sut.login(.success(userA())) { _ in }

        var receivedError: Error?
        try? sut.logout { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDeleteSuccessfully()

        wait(for: [exp], timeout: 1.0)

        XCTAssertNil(receivedError)
    }

    func test_save_doesNotDeliveryLoginErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = UserStoreSpy()
        var sut: LocalUserLoader? = LocalUserLoader(store: store)

        var receivedError: Error?

        sut?.login(.success(userA()), completion: { error in
            receivedError = error
        })

        sut = nil

        store.completeSave(with: anyError())

        XCTAssertNil(receivedError)
    }

    func test_save_doesNotDeliveryLogoutErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = UserStoreSpy()
        var sut: LocalUserLoader? = LocalUserLoader(store: store)

        var receivedError: Error?

        try? sut?.logout { error in
            receivedError = error
        }

        sut = nil

        store.completeDelete(with: anyError())

        XCTAssertNil(receivedError)
    }

    func test_load_requestsCoreDataRetriveal() {
        let (sut, store) = makeSUT()

        sut.load() { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyError()
        let exp = expectation(description: "Wait for load completion")

        var receivedError: Error?
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) insted")
            }
            exp.fulfill()
        }

        store.completeRetrieval(with: retrievalError)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError, retrievalError)
    }

    func test_load_deliversNoUserDataOnEmptyCache() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for load completion")

        var receivedUser: User?
        sut.load { result in
            switch result {
            case let .success(user):
                receivedUser = user
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyData()

        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(receivedUser)
    }

    func test_load_deliversStoredUserOnCoreData() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        let existedUser = localUserA()

        var receivedUser: User?
        sut.load { result in
            switch result {
            case let .success(user):
                receivedUser = user
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrieval(with: existedUser.localUser)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedUser?.name, existedUser.name)
        XCTAssertEqual(receivedUser?.idToken, existedUser.idToken)
        XCTAssertEqual(receivedUser?.image, existedUser.image)
        XCTAssertEqual(receivedUser?.loginType.rawValue, existedUser.loginType.rawValue)
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
}
