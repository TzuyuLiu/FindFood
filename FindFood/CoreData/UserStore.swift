//
//  UserStore.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/27.
//

import Foundation

public enum RetrieveCachedUserResult {
    case empty
    case found(LocalUser)
    case failure(Error)
}

protocol UserStore {
    var user: LocalUser? { get }
    typealias InsertionCompletions = (Error?) -> Void
    typealias DeletionCompletions = (Error?) -> Void
    typealias RetrievalCompletions = (RetrieveCachedUserResult) -> Void

    func save(_ user: LocalUser, completion: @escaping InsertionCompletions)
    func deleteUser(completion: @escaping DeletionCompletions)
    func retrieve(completion: @escaping RetrievalCompletions)
}

