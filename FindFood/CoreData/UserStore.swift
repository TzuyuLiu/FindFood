//
//  UserStore.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/27.
//

import Foundation

public enum RetrieveStoredUserResult {
    case empty
    case found(User)
    case failure(Error)
}

protocol UserStore {
    var user: User? { get }
    typealias InsertionCompletions = (Error?) -> Void
    typealias DeletionCompletions = (Error?) -> Void
    typealias RetrievalCompletions = (RetrieveStoredUserResult) -> Void

    func save(_ user: User, completion: @escaping InsertionCompletions)
    func deleteUser(completion: @escaping DeletionCompletions)
    func retrieve(completion: @escaping RetrievalCompletions)
}

