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
    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retrieve(completion: @escaping UserStore.RetrievalCompletions) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        let decoder = JSONDecoder()
        do {
            let cache = try decoder.decode(CodableLocalUser.self, from: data)
            completion(.found(cache.localUser))
        } catch let error {
            completion(.failure(error))
        }
    }

    func insert(_ user: CodableLocalUser, completion: @escaping UserStore.InsertionCompletions) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(user)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableUserStoreTest: XCTestCase {
    // 非 class mehtods 的 setUp 會在每一個 test 測試開始前都會呼叫
    override func setUp() {
        super.setUp()
        deleteStoreArtifacts()
    }


    // 注意不要 overide 到 `override class func setUp`(class method)
    // class methods 的 setUp 只會呼叫一次，並且 tearDown 會在『所有』 test 完成才執行
    // 而非 class mehtods 的 tearDown 則是每一個 test 測試完成後都會呼叫
    override func tearDown() {
        super.tearDown()
        deleteStoreArtifacts()
    }


    func test_retrieve_deilversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
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

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let user = makeCodableLocalUser()

        insert(user, to: sut)

        expect(sut, toRetrieve: .found(user.localUser))
    }

    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let user = makeCodableLocalUser()
        
        insert(user, to: sut)
        
        expect(sut, toRetrieveTwice: .found(user.localUser))
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(makeAnyError()))
    }

    // MARK: - Helper

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableUserStore {
        let sut = CodableUserStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: CodableUserStore, toRetrieve expectedResult: RetrieveCachedUserResult, file: StaticString = #file, line: UInt = #line) {
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedUser), .found(retrievedUser)):
                XCTAssertEqual(retrievedUser, expectedUser)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }
        }
    }

    private func expect(_ sut: CodableUserStore, toRetrieveTwice expectedResult: RetrieveCachedUserResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    private func insert(_ cache: CodableLocalUser, to sut: CodableUserStore) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(cache) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func testSpecificStoreURL() -> URL {
        // type(of: self): 取得自己的 class name (CodableFeedStoreTests)
        return  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
