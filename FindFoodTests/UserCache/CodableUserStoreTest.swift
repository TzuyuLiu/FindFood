//
//  CodableUserStoreTest.swift
//  FindFoodTests
//
//  Created by 劉子瑜-20001220 on 2024/6/28.
//

import XCTest
@testable import FindFood

public enum CodableLocalLoginType: String, Equatable, Codable {
    case google
    case facebook
}

// 用來消除模組間的強耦合(UserStore 對上 User)
public struct CodableLocalUser: Equatable, Codable {
    let name: String
    let image: URL?
    let idToken: String
    let loginType: CodableLocalLoginType // 用來判斷是用什麼軟體登入

    // 其他 module 會產生 FeedLoader，因此其他 module 也會使用到
    public init(name: String, image: URL?, idToken: String, loginType: CodableLocalLoginType) {
        self.name = name
        self.image = image
        self.idToken = idToken
        self.loginType = loginType
    }

    var localUser: LocalUser {
        return LocalUser(name: self.name, image: self.image, idToken: self.idToken, loginType: LocalLoginType(rawValue: self.loginType.rawValue) ?? .facebook)
    }
}

class CodableUserStore {
    func retrieve(completion: @escaping UserStore.RetrievalCompletions) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        let decoder = JSONDecoder()
        let cache = try! decoder.decode(CodableLocalUser.self, from: data)
        completion(.found(cache.localUser))
    }

    func insert(_ user: CodableLocalUser, completion: @escaping UserStore.InsertionCompletions) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(user)
        try! encoded.write(to: storeURL)
        completion(nil)
    }

    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("User.store")
}

final class CodableUserStoreTest: XCTestCase {
    // 非 class mehtods 的 setUp 會在每一個 test 測試開始前都會呼叫
    override func setUp() {
        super.setUp()

        // 避免有時候沒有呼叫到 tearDown (e.g. 設定 breakpoint 並直接停止 test)
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("User.store")

        try? FileManager.default.removeItem(at: storeURL)
    }


    // 注意不要 overide 到 `override class func setUp`(class method)
    // class methods 的 setUp 只會呼叫一次，並且 tearDown 會在『所有』 test 完成才執行
    // 而非 class mehtods 的 tearDown 則是每一個 test 測試完成後都會呼叫
    override func tearDown() {
        super.tearDown()

        // 避免數值被儲存，導致下次執行 test empty 的時候會有 side effect
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("User.store")

        try? FileManager.default.removeItem(at: storeURL)
    }


    func test_retrieve_deilversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty result, got \(firstResult) and \(secondResult) instead.")
                }

                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let user = makeCodableLocalUser()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(user) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")

            sut.retrieve { retrieveResult in
                switch (retrieveResult) {
                case let (.found(retrieveUser)):
                    XCTAssertEqual(retrieveUser.name, user.name)
                    XCTAssertEqual(retrieveUser.idToken, user.idToken)
                    XCTAssertEqual(retrieveUser.image, user.image)
                    XCTAssertEqual(retrieveUser.loginType.rawValue, user.loginType.rawValue)
                default:
                    XCTFail("Expected found result with user \(user), got \(retrieveResult) instead")
                }

                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helper

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableUserStore {
        let sut = CodableUserStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
