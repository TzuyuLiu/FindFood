//
//  CodableUserStoreTest.swift
//  FindFoodTests
//
//  Created by 劉子瑜-20001220 on 2024/6/28.
//

import XCTest
@testable import FindFood

class CodableUserStore {
    func retrieve(completion: @escaping UserStore.RetrievalCompletions) {
        completion(.empty)
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
        let sut = CodableUserStore()
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
        let sut = CodableUserStore()
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
        let sut = CodableUserStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be insertd successfully")

            sut.retrieve { retrieveResult in
                switch (retrieveResult) {
                case let (.found(feed: retrieveFeed, timestamp: retrieveTimestamp)):
                    XCTAssertEqual(retrieveFeed, feed)
                    XCTAssertEqual(retrieveTimestamp, timestamp)
                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
                }

                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
}
