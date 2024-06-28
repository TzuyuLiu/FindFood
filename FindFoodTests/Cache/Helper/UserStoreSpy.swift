//
//  UserStoreSpy.swift
//  FindFoodTests
//
//  Created by 劉子瑜-20001220 on 2024/6/28.
//

import Foundation
@testable import FindFood

class UserStoreSpy: UserStore {
    enum ReceivedMessage: Equatable {
        case save
        case delete
        case retrieve
    }

    private(set) var user: User?
    private var saveCompletion: SaveCompletions?
    private var deleteCompletion: DeleteCompletions?
    private var retrieveCompletion: RetrieveCompletions?

    private(set) var receivedMessages = [ReceivedMessage]()

    typealias SaveCompletions = (Error?) -> Void

    func save(_ user: User, completion: @escaping SaveCompletions) {
        self.user = user
        saveCompletion = completion
        receivedMessages.append(.save)
    }

    func deleteUser(completion: @escaping DeleteCompletions) {
        self.user = nil
        deleteCompletion = completion
        receivedMessages.append(.delete)
    }

    func retrieve(completion: @escaping RetrieveCompletions) {
        retrieveCompletion = completion
        receivedMessages.append(.retrieve)
    }

    func completeSave(with error: Error) {
        saveCompletion?(error)
    }

    func completeSaveSuccessfully() {
        saveCompletion?(nil)
    }

    func completeDelete(with error: Error) {
        deleteCompletion?(error)
    }

    func completeDeleteSuccessfully() {
        deleteCompletion?(nil)
    }

    func completeRetrieval(with error: Error) {
        retrieveCompletion?(.failure(error))
    }

    func completeRetrievalWithEmptyData() {
        retrieveCompletion?(.empty)
    }

    func completeRetrieval(with user: User) {
        retrieveCompletion?(.found(user))
    }
}
